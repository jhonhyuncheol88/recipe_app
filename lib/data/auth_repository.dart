import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../model/app_user.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 사용자가 로그인 다이얼로그를 직접 닫은 경우 호출자(BLoC)가 silent fail
/// 처리할 수 있게 sentinel 예외를 던진다.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  /// Firebase Console / `google-services.json` 의 Web client ID (`client_type: 3`).
  /// Android 에서 idToken 발급 및 Auth 연동 시 권장.
  static const String _googleWebClientId =
      '584875089226-1a8m5mnol7ap58bqtivd97no1uu5bmj6.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const <String>['email', 'profile'],
    serverClientId: _googleWebClientId,
  );

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  /// 매번 계정 선택 화면을 강제로 띄우기 위한 Google 로그인.
  ///
  /// - iOS: `google_sign_in_ios` (AppAuth 기반) 가 Safari 쿠키를 공유해
  ///   계정이 1개 캐시돼 있으면 picker 없이 바로 진행되는 이슈가 있어,
  ///   Firebase Auth `signInWithProvider` + `prompt=select_account` 로 우회.
  /// - Android: `google_sign_in.signOut()` 으로 캐시된 계정을 비운 뒤
  ///   `signIn()` 을 호출하면 항상 계정 선택 시트가 뜬다.
  /// 사용자가 흐름을 취소하면 [AuthCancelledException] 으로 매핑.
  Future<UserCredential> signInWithGoogle() async {
    if (!kIsWeb && Platform.isIOS) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'})
        ..addScope('email')
        ..addScope('profile');
      final UserCredential userCred;
      try {
        userCred = await _firebaseAuth.signInWithProvider(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'web-context-canceled' ||
            e.code == 'canceled' ||
            e.code == 'user-cancelled') {
          throw const AuthCancelledException();
        }
        rethrow;
      }
      await _createOrUpdateUserDocument(userCred);
      return userCred;
    }

    // Android: 캐시된 계정을 비워야 picker 가 매번 나타난다.
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      _log.w('[signInWithGoogle] pre-signOut ignore: $e');
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw const AuthCancelledException();
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in returned no idToken');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    await _createOrUpdateUserDocument(userCred);
    return userCred;
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final userCred = await _firebaseAuth.signInWithCredential(oauthCredential);

    // Apple 은 첫 로그인 시에만 fullName 을 돌려준다. Firebase user.displayName
    // 가 비어 있으면 들어온 이름으로 채워준다.
    if (userCred.user != null &&
        (userCred.user!.displayName == null ||
            userCred.user!.displayName!.isEmpty)) {
      final given = appleCredential.givenName ?? '';
      final family = appleCredential.familyName ?? '';
      final combined = '$given $family'.trim();
      if (combined.isNotEmpty) {
        await userCred.user!.updateDisplayName(combined);
        await userCred.user!.reload();
      }
    }

    await _createOrUpdateUserDocument(userCred);
    return userCred;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      _log.w('[signOut] google signOut ignore: $e');
    }
    await _firebaseAuth.signOut();
  }

  /// Firebase user 와 Firestore users/{uid} 문서를 삭제한다.
  /// requires-recent-login 발생 시 호출자가 reauth 후 재시도.
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }

    final uid = user.uid;
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      _log.w('[deleteAccount] firestore doc delete ignore: $e');
    }

    await user.delete();

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // 무시 — user.delete() 후 google session 정리는 best-effort
    }
  }

  Future<void> _createOrUpdateUserDocument(UserCredential userCred) async {
    final user = userCred.user;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final isFirstSignIn = userCred.additionalUserInfo?.isNewUser ?? false;

    // isPremium 은 [AppUser.signInMergePayload] 에서 첫 로그인 때만 false.
    // 이후 클라이언트 writes 에는 포함하지 않음 — rules + Webhook 만 갱신.
    final data = AppUser.signInMergePayload(
      user: user,
      isFirstSignIn: isFirstSignIn,
    );

    try {
      await docRef.set(data, SetOptions(merge: true));
    } catch (e, st) {
      _log.e(
        '[_createOrUpdateUserDocument] Firestore write failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
