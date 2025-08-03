import 'package:flutter/material.dart';

/// Central panel showing the virtual pet.
/// For now it just displays a placeholder and the pet level.
class PetDisplayArea extends StatelessWidget {
  const PetDisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Enhanced responsive breakpoints
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 800;
    final isSmallScreen = screenSize.width < 360;
    
    // Improved size ratio calculations
    double getNestWidth() {
      if (isLargeScreen) return screenSize.width * 0.35;
      if (isTablet) return screenSize.width * 0.4;
      if (isSmallScreen) return screenSize.width * 0.6;
      return screenSize.width * 0.5;
    }
    
    double getEggRatio() {
      if (isLargeScreen) return 0.35;
      if (isTablet) return 0.32;
      return 0.38; // Slightly larger on mobile for better visibility
    }
    
    final nestWidth = getNestWidth();
    final nestHeight = nestWidth * 0.65; // Improved aspect ratio for nest
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flexible spacing
              Flexible(flex: 1, child: SizedBox.shrink()),
              
              // Pet nest area - enhanced stack with proper positioning
              Flexible(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, stackConstraints) {
                    // Calculate available space for optimal sizing
                    final availableWidth = stackConstraints.maxWidth;
                    final availableHeight = stackConstraints.maxHeight;
                    
                    // Constrain nest size to available space
                    final constrainedNestWidth = nestWidth.clamp(0.0, availableWidth * 0.9);
                    final constrainedNestHeight = nestHeight.clamp(0.0, availableHeight * 0.9);
                    final constrainedEggSize = (constrainedNestWidth * getEggRatio()).clamp(0.0, constrainedNestHeight * 0.6);
                    
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pet egg positioned at bottom of nest for better visual hierarchy
                        Positioned(
                          bottom: constrainedNestHeight * 5.0, // Near bottom for realistic nest placement
                          child: Image.asset(
                            'assets/mypage/pet/pet_egg.png',
                            width: constrainedEggSize,
                            height: constrainedEggSize,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Nest background
                        Positioned(
                          child: Image.asset(
                            'assets/mypage/pet/nest.png',
                            width: constrainedNestWidth,
                            height: constrainedNestHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Responsive spacing
              SizedBox(height: screenSize.height * 0.02),
              
              // // Interaction message box - responsive sizing
              // Flexible(
              //   flex: 1,
              //   child: Image.asset(
              //     'assets/mypage/pet/interation_message_box.png', 
              //     width: messageBoxWidth, 
              //     height: messageBoxHeight,
              //     fit: BoxFit.contain,
              //   ),
              // ),
              
              // // Level text with responsive spacing
              SizedBox(height: screenSize.height * 2.0),
              
              // TextField(
              //   'name_pet', 
              //   style: TextStyle(
              //     fontFamily: 'DungGeunMo', 
              //     fontSize: isLargeScreen ? 24 : 20, // Responsive font size
              //     border: Border.all(color: Colors.black54, width: 1.5),
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
                              

              // Bottom flexible spacing
              Flexible(flex: 1, child: SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}
