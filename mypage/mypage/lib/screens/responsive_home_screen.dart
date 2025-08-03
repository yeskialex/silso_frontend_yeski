import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/responsive_pet_display.dart';
import '../widgets/responsive_app_bar.dart';
import '../widgets/pet_status_panel.dart';

/// Clean responsive implementation transforming hardcoded design to flexible layout
class ResponsiveHomeScreen extends StatelessWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Design constants from iPhone 16 (393x852)
    const designWidth = 393.0;
    const designHeight = 852.0;
    
    // Calculate responsive scale factors
    final scaleX = screenSize.width / designWidth;
    final scaleY = screenSize.height / designHeight;
    final uniformScale = (scaleX + scaleY) / 2;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image - Responsive
            Positioned(
              left: -42 * scaleX,
              top: -6 * scaleY,
              child: Container(
                width: 473 * scaleX,
                height: 860 * scaleY,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/mypage/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Main Content
            Column(
              children: [
                // Status Bar
                _buildStatusBar(screenSize, uniformScale),
                
                // App Bar with proper spacing
                const MyHomeAppBar(),
                
                // Status Panel - Fixed overflow issue
                const PetStatusPanel(),
                
                // Pet Display Area
                Expanded(
                  child: ResponsivePetDisplay(scale: uniformScale),
                ),
                
                // Action Toolbar
                _buildActionToolbar(context, screenSize, uniformScale),
                
                // Bottom Navigation
                _buildBottomNavigation(screenSize, uniformScale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(Size screenSize, double scale) {
    return Container(
      height: 5 * scale,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
      // Empty status bar area to maintain layout spacing without hardcoded elements
    );
  }


  Widget _buildActionToolbar(BuildContext context, Size screenSize, double scale) {
    final provider = context.read<PetProvider>();
    
    return Container(
      height: 130 * scale,
      padding: EdgeInsets.symmetric(horizontal: 21 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('청소', 'assets/mypage/button/clean.png', provider.clean, scale),
          _buildActionButton('놀기', 'assets/mypage/button/play.png', provider.play, scale),
          _buildActionButton('먹이', 'assets/mypage/button/feed.png', provider.feed, scale),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String iconPath, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 112 * scale,
        height: 107 * scale,
        child: Stack(
          alignment: Alignment.center, // Center align all children
          children: [
            Image.asset(
              'assets/mypage/button/button_container.png',
              width: 112 * scale,
              height: 107 * scale,
              fit: BoxFit.contain,
            ),
            // Centered icon with better coverage
            Center(
              child: Image.asset(
                iconPath,
                width: 85 * scale, // Increased from 71 for better coverage
                height: 60 * scale, // Increased from 50 for better coverage
                fit: BoxFit.cover, // Changed to cover for better container fill
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(Size screenSize, double scale) {
    return Container(
      height: 80 * scale,
      color: const Color(0x0CFAFAFA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('홈', true, scale),
          _buildNavItem('커뮤니티', false, scale),
          _buildNavItem('콘텐츠', false, scale),
          _buildNavItem('놀이터', false, scale),
          _buildNavItem('마이페이지', false, scale),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, bool isSelected, double scale) {
    return SizedBox(
      width: 65 * scale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24 * scale,
            height: 24 * scale,
            child: Icon(
              Icons.home,
              size: 24 * scale,
              color: isSelected 
                ? const Color(0xFF5F37CF) 
                : const Color(0xFF121212).withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * scale,
              color: isSelected 
                ? const Color(0xFF5F37CF) 
                : const Color(0xFF121212).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}