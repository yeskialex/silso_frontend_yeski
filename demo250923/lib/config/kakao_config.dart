class AuthConfig {
  // Kakao Application Keys
  static const String kakaoRestApiKey = '9b1309a06067eedd2ebc6f3ddc3a65d0';
  static const String kakaoJavascriptKey = '3d1ed1dc6cd2c4797f2dfd65ee48c8e8';
  static const String kakaoNativeAppKey = '3c7a8b482a7de8109be0c367da2eb33a';

  // Google Client ID
  static const String googleWebClientId = '337349884372-lg6d6u7bmf7pbvebrfhr4s2i5rffds0o.apps.googleusercontent.com';

  // Google OAuth Scopes
  static const List<String> googleScopes = [
    'email',
    'openid',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

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
}
