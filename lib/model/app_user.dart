import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore `users/{uid}` 프로필 문서.
///
/// 클라이언트는 로그인 시 프로필 필드만 [signInMergePayload] 로 갱신하고,
/// `isPremium`·`premium_*` 는 Webhook(Admin SDK) 만 수정한다.
class AppUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isPremium;
  final DateTime? premiumUpdatedAt;
  final String? premiumProductId;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastSignInAt,
    this.isPremium = false,
    this.premiumUpdatedAt,
    this.premiumProductId,
  });

  /// 로그인 직후 `set(..., merge: true)` 용 필드 맵.
  static Map<String, dynamic> signInMergePayload({
    required User user,
    required bool isFirstSignIn,
  }) {
    return <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignInAt': FieldValue.serverTimestamp(),
      if (isFirstSignIn) ...<String, dynamic>{
        'createdAt': FieldValue.serverTimestamp(),
        'isPremium': false,
      },
    };
  }

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    if (d == null) {
      return AppUser(uid: doc.id);
    }
    return AppUser(
      uid: d['uid'] as String? ?? doc.id,
      email: d['email'] as String?,
      displayName: d['displayName'] as String?,
      photoURL: d['photoURL'] as String?,
      createdAt: _dateTimeFromFirestore(d['createdAt']),
      lastSignInAt: _dateTimeFromFirestore(d['lastSignInAt']),
      isPremium: d['isPremium'] == true,
      premiumUpdatedAt: _dateTimeFromFirestore(d['premiumUpdatedAt']),
      premiumProductId: d['premiumProductId'] as String?,
    );
  }

  static DateTime? _dateTimeFromFirestore(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        createdAt,
        lastSignInAt,
        isPremium,
        premiumUpdatedAt,
        premiumProductId,
      ];
}
