import 'package:flutter/material.dart';
import '../controllers/splash_screen_controller.dart';
import '../views/splash_screen_view.dart';

/// Splash screen page wrapper implementing MVC pattern
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late final SplashScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashScreenController();
    _controller.addListener(_onControllerChanged);
    
    // Initialize controller with context after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(context);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Handle controller state changes
  void _onControllerChanged() {
    // UI will automatically rebuild due to setState calls in controller
    // Additional UI-specific logic can be added here if needed
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to listen to controller changes
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return const SplashScreenView();
      },
    );
  }
}

/// Extension for debugging and development
extension SplashScreenPageDebug on _SplashScreenPageState {
  /// Debug method to print current state
  void debugPrintState() {
    debugPrint('=== Splash Screen State ===');
    debugPrint('Is Loading: ${_controller.model.isLoading}');
    debugPrint('Is Completed: ${_controller.model.isCompleted}');
    debugPrint('===========================');
  }
  
  /// Skip splash for testing
  void skipSplash() {
    _controller.skipSplash();
  }
}