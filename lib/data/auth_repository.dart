import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // Google Sign-In 초기화
      await _googleSignIn.initialize(
        clientId: null, // Android는 google-services.json에서 자동 설정
        serverClientId: null, // 필요시 설정
      );

      // 사용자 인증
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null;

      // 인증 정보 가져오기 (기본 스코프 요청)
      final List<String> scopes = ['email', 'profile'];

      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(scopes);

      if (authorization == null) {
        throw Exception('Google 인증 정보를 가져올 수 없습니다');
      }

      // Firebase 인증 정보 생성 (accessToken만 사용)
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: null, // 최신 버전에서는 accessToken만으로도 인증 가능
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // 새 사용자인 경우 Firestore에 사용자 데이터 저장
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential.user;
    } catch (e) {
      throw Exception('Google 로그인 실패: $e');
    }
  }

  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
