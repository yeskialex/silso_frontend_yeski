import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Retro-style app bar with left logo, center title, and right hamburger icon.
class MyHomeAppBar extends StatelessWidget {
  const MyHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    // Responsive sizing
    final logoSize = isTablet ? 40.0 : 32.0;
    final menuSize = isTablet ? 32.0 : 28.0;
    final fontSize = isTablet ? 26.0 : 22.0;
    final topPadding = screenSize.height * 0.04;
    final horizontalPadding = screenSize.width * 0.04;
    
    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: screenSize.height * 0.01,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo with responsive sizing
          Image.asset(
            'assets/mypage/appbar/logo.png', 
            width: logoSize, 
            height: logoSize,
            fit: BoxFit.contain,
          ),
          
          // Title with responsive font size
          Flexible(
            child: Text(
              'My Home',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'DungGeunMo',
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Menu icon with responsive sizing
          SvgPicture.asset(
            'assets/mypage/appbar/menu.svg', 
            width: menuSize, 
            height: menuSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
