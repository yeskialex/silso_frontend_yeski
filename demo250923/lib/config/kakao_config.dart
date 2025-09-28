class AuthConfig {
  // Kakao Application Keys
  static const String kakaoRestApiKey = '9b1309a06067eedd2ebc6f3ddc3a65d0';
  static const String kakaoJavascriptKey = '3d1ed1dc6cd2c4797f2dfd65ee48c8e8';
  static const String kakaoNativeAppKey = '3c7a8b482a7de8109be0c367da2eb33a';

  // Google Client ID
  static const String googleWebClientId = '337349884372-lg6d6u7bmf7pbvebrfhr4s2i5rffds0o.apps.googleusercontent.com';

  // Backend Server URL
  static const String backendUrl = 'https://api-3ezpz5haxq-uc.a.run.app';

  // Note: Client secret should never be exposed in client-side code
  // It's properly stored in the backend server's .env file

  // OAuth Scopes
  static const List<String> kakaoScopes = [
    'profile_nickname',
    'profile_image',
    'account_email'
  ];

  // OAuth URLs
  static const String kakaoAuthorizeUrl = 'https://kauth.kakao.com/oauth/authorize';
  static const String kakaoTokenUrl = 'https://kauth.kakao.com/oauth/token';
  static const String kakaoUserInfoUrl = 'https://kapi.kakao.com/v2/user/me';
}

// Keep KakaoConfig for backward compatibility
class KakaoConfig {
  static const String restApiKey = AuthConfig.kakaoRestApiKey;
  static const String javascriptKey = AuthConfig.kakaoJavascriptKey;
  static const String nativeAppKey = AuthConfig.kakaoNativeAppKey;
  static const List<String> defaultScopes = AuthConfig.kakaoScopes;
  static const String authorizeUrl = AuthConfig.kakaoAuthorizeUrl;
  static const String tokenUrl = AuthConfig.kakaoTokenUrl;
  static const String userInfoUrl = AuthConfig.kakaoUserInfoUrl;
}