import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pet_provider.dart';

/// Toolbar with actions the user can take: Clean, Play, Feed.
class ActionToolbar extends StatelessWidget {
  const ActionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PetProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    // Enhanced responsive sizing for better button coverage
    final buttonSize = screenSize.width * (isTablet ? 0.12 : 0.15);
    final iconSize = buttonSize * 0.65; // Increased icon size to better fill background
    final fontSize = isTablet ? 12.0 : 10.0;
    final horizontalPadding = screenSize.width * 0.05;
    
    Widget action(String label, String assetPath, VoidCallback onTap) => Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/mypage/button/button_container.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Icon positioned to cover the button background area optimally
                    Positioned(
                      top: buttonSize * 0.18, // Better vertical positioning
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        child: Image.asset(
                          assetPath, 
                          width: iconSize, 
                          height: iconSize,
                          fit: BoxFit.cover, // Changed to cover for better background filling
                        ),
                      ),
                    ),
                    // Label positioned at bottom with proper spacing
                    Positioned(
                      bottom: buttonSize * 0.08, // Adjusted for better visual balance
                      child: Text(
                        label, 
                        style: TextStyle(
                          fontFamily: 'DungGeunMo', 
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Ensure text visibility
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenSize.height * 0.015,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              action('청소', 'assets/mypage/button/clean.png', provider.clean),
              action('놀기', 'assets/mypage/button/play.png', provider.play),
              action('먹이', 'assets/mypage/button/feed.png', provider.feed),
            ],
          ),
        );
      },
    );
  }
}
