import 'package:firebase_auth/firebase_auth.dart';

class KoreanAuthService {
  static final KoreanAuthService _instance = KoreanAuthService._internal();
  factory KoreanAuthService() => _instance;
  KoreanAuthService._internal();

  static Future<void> initialize({
    required String kakaoAppKey,
    String? nativeAppKey,
  }) async {
    throw UnsupportedError('Kakao authentication not supported on this platform');
  }

  Future<UserCredential?> signInWithKakao() async {
    throw UnsupportedError('Kakao authentication not supported on this platform');
  }


  Future<UserCredential?> handleOAuthCallbackOnly() async => null;

  Future<void> signOutKakaoServices() async {
    // No-op for unsupported platforms
  }
}