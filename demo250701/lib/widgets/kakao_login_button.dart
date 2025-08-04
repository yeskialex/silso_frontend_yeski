import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../utils/responsive_asset_manager.dart';

class KakaoLoginButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool isLoading;
  final bool useEnglish;
  final bool useAssetImage;

  const KakaoLoginButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.isLoading = false,
    this.useEnglish = false,
    this.useAssetImage = true,
  });

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  final _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _handleKakaoSignIn() async {
    if (_isSigningIn || widget.isLoading) return;

    setState(() => _isSigningIn = true);

    try {
      // Check backend server health first
      bool isBackendHealthy = await _authService.checkBackendHealth();
      
      if (!isBackendHealthy) {
        throw 'Authentication server is not available. Please try again later.';
      }

      // Attempt real Kakao sign-in
      await _authService.signInWithKakao();
      
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useAssetImage) {
      return _buildAssetButton(context);
    } else {
      return _buildCustomButton(context);
    }
  }
  
  /// Build button using responsive Kakao assets
  Widget _buildAssetButton(BuildContext context) {
    final buttonSize = AppAssetProvider.getResponsiveButtonSize(
      context,
      baseSize: const Size(360, 52),
    );
    
    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: GestureDetector(
        onTap: (_isSigningIn || widget.isLoading) ? null : _handleKakaoSignIn,
        child: Stack(
          children: [
            // Kakao asset image
            Container(
              width: buttonSize.width,
              height: buttonSize.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AppAssetProvider.getPath(
                    context,
                    AppAsset.kakaoSignin,
                  ),
                  width: buttonSize.width,
                  height: buttonSize.height,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => _buildCustomButton(context),
                ),
              ),
            ),
            
            // Loading overlay
            if (_isSigningIn || widget.isLoading)
              Container(
                width: buttonSize.width,
                height: buttonSize.height,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build custom button as fallback
  Widget _buildCustomButton(BuildContext context) {
    final buttonSize = AppAssetProvider.getResponsiveButtonSize(
      context,
      baseSize: const Size(360, 52),
    );
    
    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: ElevatedButton.icon(
        onPressed: (_isSigningIn || widget.isLoading) ? null : _handleKakaoSignIn,
        icon: _isSigningIn 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              )
            : _buildKakaoIcon(),
        label: Text(
          _isSigningIn ? '로그인 중...' : (widget.useEnglish ? 'Login with Kakao' : '카카오톡으로 로그인'),
          style: TextStyle(
            fontSize: 16 * (buttonSize.width / 360),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE812), // Kakao yellow
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoIcon() {
    // Use a simple chat bubble icon since we don't have the official Kakao icon
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.chat_bubble,
        size: 12,
        color: Color(0xFFFFE812),
      ),
    );
  }
}

// Alternative Kakao button with Korean text and styling
class KakaoLoginButtonKorean extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool isLoading;

  const KakaoLoginButtonKorean({
    super.key,
    this.onSuccess,
    this.onError,
    this.isLoading = false,
  });

  @override
  State<KakaoLoginButtonKorean> createState() => _KakaoLoginButtonKoreanState();
}

class _KakaoLoginButtonKoreanState extends State<KakaoLoginButtonKorean> {
  final _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _handleKakaoSignIn() async {
    if (_isSigningIn || widget.isLoading) return;

    setState(() => _isSigningIn = true);

    try {
      // Check backend server health first
      bool isBackendHealthy = await _authService.checkBackendHealth();
      
      if (!isBackendHealthy) {
        throw 'Authentication server is not available. Please try again later.';
      }

      // Attempt real Kakao sign-in
      await _authService.signInWithKakao();
      
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE812), // Kakao yellow
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (_isSigningIn || widget.isLoading) ? null : _handleKakaoSignIn,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSigningIn)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  else
                    _buildKakaoLogo(),
                  const SizedBox(width: 12),
                  Text(
                    _isSigningIn ? '로그인 중...' : '카카오 로그인',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoLogo() {
    // Kakao-style logo using chat bubble icon
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.chat_bubble_rounded,
        size: 16,
        color: Color(0xFFFFE812),
      ),
    );
  }
}

// Simple Kakao button variant
class KakaoLoginButtonSimple extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool isLoading;

  const KakaoLoginButtonSimple({
    super.key,
    this.onSuccess,
    this.onError,
    this.isLoading = false,
  });

  @override
  State<KakaoLoginButtonSimple> createState() => _KakaoLoginButtonSimpleState();
}

class _KakaoLoginButtonSimpleState extends State<KakaoLoginButtonSimple> {
  final _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _handleKakaoSignIn() async {
    if (_isSigningIn || widget.isLoading) return;

    setState(() => _isSigningIn = true);

    try {
      await _authService.signInWithKakao();
      
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: (_isSigningIn || widget.isLoading) ? null : _handleKakaoSignIn,
        icon: _isSigningIn 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFE812)),
                ),
              )
            : Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE812),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat,
                  size: 12,
                  color: Colors.black87,
                ),
              ),
        label: Text(
          _isSigningIn ? 'Signing in...' : 'Continue with Kakao',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}