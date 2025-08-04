import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final bool isLoading;
  final double? widthRatio;
  final double? heightRatio;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.isLoading = false,
    this.widthRatio,
    this.heightRatio,
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
    if (kIsWeb) {
      // For web, show a custom button since renderButton requires DOM manipulation
      return _buildCustomButton();
    } else {
      // For mobile, show the standard button
      return _buildCustomButton();
    }
  }

  Widget _buildCustomButton() {
    final double widthRatio = widget.widthRatio ?? 1.0;
    final double heightRatio = widget.heightRatio ?? 1.0;

    return SizedBox(
      width: 360 * widthRatio,
      height: 52 * heightRatio,
      child: ElevatedButton(
        onPressed: (_isSigningIn || widget.isLoading) ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
          foregroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * widthRatio),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * widthRatio,
            vertical: 14 * heightRatio,
          ),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.15),
        ),
        child: _isSigningIn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20 * widthRatio,
                    height: 20 * heightRatio,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                    ),
                  ),
                  SizedBox(width: 12 * widthRatio),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 16 * widthRatio,
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
                    'assets/images/google_signin/google_logo.png',
                    width: 50 * widthRatio,
                    height: 50 * heightRatio,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: 12 * widthRatio),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16 * widthRatio,
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
}