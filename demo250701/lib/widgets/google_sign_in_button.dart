import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/responsive_asset_manager.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool isLoading;
  final bool useFullButton;
  final bool useAssetImage;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.isLoading = false,
    this.useFullButton = false,
    this.useAssetImage = true,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isSigningIn || widget.isLoading) return;

    setState(() => _isSigningIn = true);

    try {
      await _authService.signInWithGoogle();
      
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
    if (widget.useAssetImage && widget.useFullButton) {
      return _buildFullAssetButton(context);
    } else if (widget.useAssetImage) {
      return _buildCustomButtonWithAssetLogo(context);
    } else {
      return _buildCustomButton(context);
    }
  }

  /// Build button using full Google signin asset
  Widget _buildFullAssetButton(BuildContext context) {
    final buttonSize = AppAssetProvider.getResponsiveButtonSize(
      context,
      baseSize: const Size(360, 52),
    );
    
    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: GestureDetector(
        onTap: (_isSigningIn || widget.isLoading) ? null : _handleGoogleSignIn,
        child: Stack(
          children: [
            // Google asset image
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
                child: ResponsiveImage.auto(
                  assetPath: AppAssetProvider.getPath(
                    context,
                    AppAsset.googleSigninButton,
                  ),
                  width: buttonSize.width,
                  height: buttonSize.height,
                  fit: BoxFit.cover,
                  preferSvg: true,
                  errorWidget: _buildCustomButtonWithAssetLogo(context),
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

  /// Build custom button with Google logo asset
  Widget _buildCustomButtonWithAssetLogo(BuildContext context) {
    final buttonSize = AppAssetProvider.getResponsiveButtonSize(
      context,
      baseSize: const Size(360, 52),
    );
    final logoSize = buttonSize.height * 0.6;

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: ElevatedButton(
        onPressed: (_isSigningIn || widget.isLoading) ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
          foregroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * (buttonSize.width / 360),
            vertical: 14 * (buttonSize.height / 52),
          ),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.15),
        ),
        child: _isSigningIn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                    ),
                  ),
                  SizedBox(width: 12 * (buttonSize.width / 360)),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 16 * (buttonSize.width / 360),
                      color: const Color(0xFF1F1F1F),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssetProvider.getPath(context, AppAsset.googleSigninButton),
                    width: logoSize,
                    height: logoSize,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => 
                        _buildGoogleIcon(logoSize),
                  ),
                  SizedBox(width: 12 * (buttonSize.width / 360)),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16 * (buttonSize.width / 360),
                      color: const Color(0xFF1F1F1F),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build basic custom button as fallback
  Widget _buildCustomButton(BuildContext context) {
    final buttonSize = AppAssetProvider.getResponsiveButtonSize(
      context,
      baseSize: const Size(360, 52),
    );
    final logoSize = buttonSize.height * 0.6;

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: ElevatedButton(
        onPressed: (_isSigningIn || widget.isLoading) ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
          foregroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * (buttonSize.width / 360),
            vertical: 14 * (buttonSize.height / 52),
          ),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.15),
        ),
        child: _isSigningIn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                    ),
                  ),
                  SizedBox(width: 12 * (buttonSize.width / 360)),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 16 * (buttonSize.width / 360),
                      color: const Color(0xFF1F1F1F),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(logoSize),
                  SizedBox(width: 12 * (buttonSize.width / 360)),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16 * (buttonSize.width / 360),
                      color: const Color(0xFF1F1F1F),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  /// Build fallback Google icon
  Widget _buildGoogleIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.g_mobiledata,
        size: size * 0.7,
        color: Colors.white,
      ),
    );
  }
}