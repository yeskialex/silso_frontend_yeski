import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Responsive MyHomeAppBar widget with precise spacing control
/// Based on 393px design specifications with proportional scaling
class MyHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyHomeAppBar({super.key});

  // Design constants based on 393px width specification
  static const double _designWidth = 393.0;
  static const double _leftPadding = 17.0;
  static const double _logoToTextGap = 11.87;
  static const double _rightPadding = 14.0;
  static const double _appBarHeight = 66.0;
  
  // Asset dimensions from original design
  static const double _logoWidth = 69.0;
  static const double _logoHeight = 25.0;
  static const double _menuIconSize = 29.0;

  @override
  Size get preferredSize => Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive scale factor
    final scale = screenSize.width / _designWidth;
    
    // Responsive dimensions
    final appBarHeight = _appBarHeight * scale;
    final leftPadding = _leftPadding * scale;
    final logoToTextGap = _logoToTextGap * scale;
    final rightPadding = _rightPadding * scale;
    final logoWidth = _logoWidth * scale;
    final logoHeight = _logoHeight * scale;
    final menuIconSize = _menuIconSize * scale;
    final fontSize = 22.0 * scale;

    return Container(
      height: appBarHeight,
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        children: [
          // Left padding
          SizedBox(width: leftPadding),
          
          // Logo asset
          Image.asset(
            'assets/mypage/appbar/logo.png',
            width: logoWidth,
            height: logoHeight,
            fit: BoxFit.contain,
          ),
          
          // Gap between logo and text (11.87px in original design)
          SizedBox(width: logoToTextGap),
          
          // Title text "마이홈"
          Text(
            '마이홈',
            style: TextStyle(
              color: const Color(0xFF121212),
              fontSize: fontSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1.05, // Line height from design
            ),
          ),
          
          // Flexible space that expands/shrinks based on screen width
          // This corresponds to the 195px gap in the original design
          const Spacer(),
          
          // Menu icon button
          GestureDetector(
            onTap: () {
              // Handle menu tap
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              width: menuIconSize,
              height: menuIconSize,
              alignment: Alignment.center,
              child: Icon(
                Icons.menu,
                size: 24.0 * scale,
                color: const Color(0xFF121212),
              ),
            ),
          ),
          
          // Right padding
          SizedBox(width: rightPadding),
        ],
      ),
    );
  }
}

/// Alternative implementation using SVG assets if available
class MyHomeAppBarSvg extends StatelessWidget implements PreferredSizeWidget {
  const MyHomeAppBarSvg({super.key});

  static const double _designWidth = 393.0;
  static const double _leftPadding = 17.0;
  static const double _logoToTextGap = 11.87;
  static const double _rightPadding = 14.0;
  static const double _appBarHeight = 66.0;
  static const double _logoWidth = 69.0;
  static const double _logoHeight = 25.0;
  static const double _menuIconSize = 29.0;

  @override
  Size get preferredSize => Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale = screenSize.width / _designWidth;
    
    final appBarHeight = _appBarHeight * scale;
    final leftPadding = _leftPadding * scale;
    final logoToTextGap = _logoToTextGap * scale;
    final rightPadding = _rightPadding * scale;
    final logoWidth = _logoWidth * scale;
    final logoHeight = _logoHeight * scale;
    final menuIconSize = _menuIconSize * scale;
    final fontSize = 22.0 * scale;

    return Container(
      height: appBarHeight,
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        children: [
          // Left padding (17px from design)
          SizedBox(width: leftPadding),
          
          // SilSo logo SVG
          SvgPicture.asset(
            'assets/mypage/appbar/silso_logo.svg',
            width: logoWidth,
            height: logoHeight,
            fit: BoxFit.contain,
          ),
          
          // Precise gap (11.87px from design)
          SizedBox(width: logoToTextGap),
          
          // "My Home" text
          Text(
            'My Home',
            style: TextStyle(
              color: const Color(0xFF121212),
              fontSize: fontSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1.05,
            ),
          ),
          
          // Flexible space (195px equivalent in original design)
          const Spacer(),
          
          // Hamburger menu IconButton
          GestureDetector(
            onTap: () {
              // Handle menu action
              Scaffold.of(context).openDrawer();
            },
            child: SvgPicture.asset(
              'assets/mypage/appbar/menu.svg',
              width: menuIconSize,
              height: menuIconSize,
              fit: BoxFit.contain,
            ),
          ),
          
          // Right padding (14px from design)
          SizedBox(width: rightPadding),
        ],
      ),
    );
  }
}

/// Utility class for AppBar spacing calculations
class AppBarSpacing {
  static const double designWidth = 393.0;
  
  /// Calculate responsive spacing based on screen width
  static double getResponsiveSpacing(BuildContext context, double originalSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / designWidth) * originalSpacing;
  }
  
  /// Get all spacing values for the AppBar
  static Map<String, double> getSpacingValues(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / designWidth;
    
    return {
      'leftPadding': 17.0 * scale,
      'logoToTextGap': 11.87 * scale,
      'rightPadding': 14.0 * scale,
      'logoWidth': 69.0 * scale,
      'logoHeight': 25.0 * scale,
      'menuIconSize': 29.0 * scale,
      'fontSize': 22.0 * scale,
      'appBarHeight': 66.0 * scale,
    };
  }
}