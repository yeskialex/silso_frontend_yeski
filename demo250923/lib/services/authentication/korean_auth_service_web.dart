import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import '../../config/kakao_config.dart';

class KoreanAuthService {
  static final KoreanAuthService _instance = KoreanAuthService._internal();
  factory KoreanAuthService() => _instance;
  KoreanAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isSignInInProgress = false;

  // Backend server URL
  static const String _backendUrl = AuthConfig.backendUrl;

  // Initialize Kakao SDK (simplified for direct OAuth)
  static Future<void> initialize({
    required String kakaoAppKey, // JavaScript key for web (not used anymore)
    String? nativeAppKey, // Native app key for mobile (not used in web)
  }) async {
    // No initialization needed for direct OAuth approach
    print('✅ Kakao web service ready for direct OAuth');
  }

  // Kakao Login for Web
  Future<UserCredential?> signInWithKakao() async {
    if (_isSignInInProgress) {
      print('⚠️ Kakao sign-in already in progress');
      return null;
    }
    
    _isSignInInProgress = true;

    try {
      print('🟡 Starting Kakao login process...');

      String? accessToken;
      
      // Check if we're returning from OAuth callback first
      accessToken = await _handleOAuthCallback();
      
      // If no callback, start OAuth flow
      if (accessToken == null) {
        accessToken = await _signInWithKakaoWeb();
      }

      if (accessToken == null) {
        throw 'Failed to get Kakao access token';
      }

      print('✅ Kakao token obtained successfully');

      // Create custom token using backend server
      String customToken = await _createCustomTokenForKakao(accessToken);
      print('✅ Firebase custom token created');
      
      // Sign in to Firebase with custom token
      UserCredential credential = await _auth.signInWithCustomToken(customToken);
      print('✅ Firebase authentication successful');
      
      return credential;
    } catch (e) {
      print('❌ Kakao login failed: $e');
      throw 'Kakao login failed: ${e.toString()}';
    } finally {
      _isSignInInProgress = false;
    }
  }

  // Web-based Kakao login using JavaScript SDK
  Future<String?> _signInWithKakaoWeb() async {
    try {
      print('🟡 Starting Kakao OAuth login...');
      
      // Redirect to Kakao OAuth (returns null since it's a redirect)
      await _callKakaoLogin();

      // This will not execute since the page redirects
      return null;
      
    } catch (e) {
      print('❌ Web Kakao login error: $e');
      rethrow;
    }
  }

  // Create custom token for Kakao using backend server
  Future<String> _createCustomTokenForKakao(String accessToken) async {
    try {
      print('🟡 Creating Firebase custom token via backend...');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/kakao/custom-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'kakao_access_token': accessToken,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Backend server timeout. Please check if the server is running.';
        },
      );

      print('📡 Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['firebase_custom_token'] != null) {
          print('✅ Custom token created successfully');
          print('⏱️ Processing time: ${data['processing_time_ms']}ms');
          return data['firebase_custom_token'];
        } else {
          throw 'Invalid response from backend server: ${data['message'] ?? 'Unknown error'}';
        }
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        throw 'Kakao access token is invalid or expired: ${data['message']}';
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw 'Bad request to backend server: ${data['message']}';
      } else if (response.statusCode >= 500) {
        final data = jsonDecode(response.body);
        throw 'Backend server error: ${data['message'] ?? 'Internal server error'}';
      } else {
        throw 'Backend server returned status ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print('❌ Backend communication error: $e');
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('timeout')) {
        throw 'Cannot connect to authentication server. Please check your internet connection and ensure the backend server is running.';
      }
      
      rethrow;
    }
  }




  // Logout from Kakao services
  Future<void> signOutKakaoServices() async {
    try {
      print('🟡 Signing out from Kakao services...');
      // For demo, just log the action
      print('✅ Kakao logout completed (demo mode)');
    } catch (e) {
      print('⚠️ Kakao services logout error: $e');
      // Don't throw error for logout - it's not critical
    }
  }

  // Handle OAuth callback when returning from Kakao login
  Future<String?> _handleOAuthCallback() async {
    try {
      // Check if current URL has authorization code
      final currentUrl = (js.globalContext.getProperty('location'.toJS) as js.JSObject).getProperty('href'.toJS).dartify() as String;
      final uri = Uri.parse(currentUrl);
      
      print('🟡 Checking OAuth callback URL: ${uri.toString()}');
      
      final authCode = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      
      if (error != null) {
        throw 'OAuth error: $error - ${uri.queryParameters['error_description'] ?? ''}';
      }
      
      if (authCode != null && authCode.isNotEmpty) {
        print('✅ Authorization code received: ${authCode.substring(0, 10)}...');
        
        // Exchange authorization code for access token
        final accessToken = await _exchangeCodeForToken(authCode);
        
        // Clean up URL by removing query parameters
        js.globalContext.callMethod('eval'.toJS, 'history.replaceState({}, document.title, window.location.pathname);'.toJS);
        
        return accessToken;
      }
      
      print('🟡 No authorization code found in URL');
      return null;
    } catch (e) {
      print('❌ OAuth callback handling failed: $e');
      rethrow;
    }
  }
  
  // Exchange authorization code for access token via backend
  Future<String> _exchangeCodeForToken(String authorizationCode) async {
    try {
      print('🟡 Exchanging authorization code for access token...');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/kakao/exchange-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'authorization_code': authorizationCode,
          'redirect_uri': (js.globalContext.getProperty('location'.toJS) as js.JSObject).getProperty('origin'.toJS).dartify() as String,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Backend server timeout during code exchange';
        },
      );

      print('📡 Code exchange response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['access_token'] != null) {
          print('✅ Access token obtained successfully');
          return data['access_token'];
        } else {
          throw 'Invalid response from backend: ${data['message'] ?? 'Unknown error'}';
        }
      } else {
        final data = jsonDecode(response.body);
        throw 'Backend error: ${data['message'] ?? 'HTTP ${response.statusCode}'}';
      }
    } catch (e) {
      print('❌ Code exchange failed: $e');
      rethrow;
    }
  }

  // Handle OAuth callback only (for app initialization)
  Future<UserCredential?> handleOAuthCallbackOnly() async {
    try {
      // Only handle callback if there's an authorization code
      final accessToken = await _handleOAuthCallback();
      
      if (accessToken != null) {
        print('🟡 Processing OAuth callback...');
        
        // Create custom token using backend server
        String customToken = await _createCustomTokenForKakao(accessToken);
        print('✅ Firebase custom token created');
        
        // Sign in to Firebase with custom token
        UserCredential credential = await _auth.signInWithCustomToken(customToken);
        print('✅ Firebase authentication successful via OAuth callback');
        
        return credential;
      }
      
      return null;
    } catch (e) {
      print('❌ OAuth callback handling failed: $e');
      return null; // Don't throw errors during app initialization
    }
  }



  Future<String?> _callKakaoLogin() async {
    try {
      // Build OAuth URL with proper client ID from config
      final currentOrigin = (js.globalContext.getProperty('location'.toJS) as js.JSObject).getProperty('origin'.toJS).dartify() as String;
      final oauthUrl = '${AuthConfig.kakaoAuthorizeUrl}?client_id=${AuthConfig.kakaoRestApiKey}&redirect_uri=${Uri.encodeComponent(currentOrigin)}&response_type=code&scope=${AuthConfig.kakaoScopes.join(',')}';

      // Direct OAuth redirect - simpler and more reliable
      print('🟡 Redirecting to Kakao OAuth...');
      js.globalContext.callMethod('eval'.toJS, '''
        window.location.href = '$oauthUrl';
      '''.toJS);

      // Return null since redirect will handle the flow
      return null;
    } catch (e) {
      print('❌ Kakao login redirect failed: $e');
      rethrow;
    }
  }
}