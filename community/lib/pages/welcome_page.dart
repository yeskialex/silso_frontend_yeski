import 'package:flutter/material.dart';
import '../views/loading_screen_view.dart';

/// Welcome page with "Join Community" button that navigates to loading screen
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF5F37CF), // Purple theme color
            ),
          ),
          
          // Bottom gradient circle
          Positioned(
            left: 0,
            right: 0,
            bottom: -130,
            child: Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      Color(0xCCFFFFFF),
                      Color(0xFF8A6BD9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '실소 커뮤니티에 참여하세요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '다양한 사람들과 소통하고\n새로운 친구를 만나보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _onJoinCommunityPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5F37CF),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Join Community',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle "Join Community" button press
  void _onJoinCommunityPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingScreenView(),
      ),
    );
  }
}