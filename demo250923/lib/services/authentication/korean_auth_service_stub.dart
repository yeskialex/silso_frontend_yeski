import 'package:firebase_auth/firebase_auth.dart';

class KoreanAuthService {
  static final KoreanAuthService _instance = KoreanAuthService._internal();
  factory KoreanAuthService() => _instance;
  KoreanAuthService._internal();

  // Stub implementations that throw unsupported errors
  static Future<void> initialize({
    required String kakaoAppKey,
    String? nativeAppKey,
  }) async {
    throw UnsupportedError('Platform not supported');
  }

  Future<UserCredential?> signInWithKakao() async {
    throw UnsupportedError('Platform not supported');
  }


  Future<bool> isKakaoSignedIn() async {
    return false;
  }

  Future<UserCredential?> handleOAuthCallbackOnly() async {
    return null;
  }

  Future<void> signOutKakaoServices() async {
    // No-op for unsupported platforms
  }


}