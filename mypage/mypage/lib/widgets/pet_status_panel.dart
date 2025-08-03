import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';

/// A helper class to hold responsive dimension constants for the status panel.
/// This centralizes layout values, making the widget tree cleaner and easier to maintain.
class _StatusPanelMetrics {
  final double labelFontSize;
  final double levelFontSize;
  final double statusGaugeHeight;
  final double levelGaugeWidth;
  final double levelGaugeHeight;
  final double xpBarBottom;
  final double xpBarWidth;
  final double xpBarMaxHeight;

  const _StatusPanelMetrics._({
    required this.labelFontSize,
    required this.levelFontSize,
    required this.statusGaugeHeight,
    required this.levelGaugeWidth,
    required this.levelGaugeHeight,
    required this.xpBarBottom,
    required this.xpBarWidth,
    required this.xpBarMaxHeight,
  });

  factory _StatusPanelMetrics.forDevice(bool isTablet) {
    return isTablet
        ? const _StatusPanelMetrics._(labelFontSize: 14.0, levelFontSize: 16.0, statusGaugeHeight: 24.0, levelGaugeWidth: 80, levelGaugeHeight: 100, xpBarBottom: 18, xpBarWidth: 48, xpBarMaxHeight: 65)
        : const _StatusPanelMetrics._(labelFontSize: 12.0, levelFontSize: 14.0, statusGaugeHeight: 18.0, levelGaugeWidth: 65, levelGaugeHeight: 85, xpBarBottom: 14, xpBarWidth: 38, xpBarMaxHeight: 55);
  }
}

/// Displays cleanliness, happiness, hunger bars and egg XP gauge.
/// Currently placeholder UI; refine with pixel-art later.
class PetStatusPanel extends StatelessWidget {
  const PetStatusPanel({super.key});

  // Design constants matching AppBar specifications
  static const double _designWidth = 393.0;
  static const double _leftPadding = 17.0; // Match AppBar logo padding

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().pet;
    final screenSize = MediaQuery.of(context).size;
    final metrics = _StatusPanelMetrics.forDevice(screenSize.width > 600);

    final scale = screenSize.width / _designWidth;
    final responsiveLeftPadding = _leftPadding * scale;
    
    Widget statusBar(String label, int value, String gaugePath) => Container(
          margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.003), // Reduced margin to prevent overflow
          child: Row(
            children: [
              SizedBox(
                width: screenSize.width * 0.15,
                child: Text(
                  label, 
                  style: TextStyle(
                    fontFamily: 'DungGeunMo',
                    fontSize: metrics.labelFontSize,
                    height: 1.0, // Constrain line height to prevent overflow
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      gaugePath, 
                      height: metrics.statusGaugeHeight,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      height: metrics.statusGaugeHeight,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0, 100) / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          // Apply left padding to match AppBar logo alignment
          padding: EdgeInsets.only(left: responsiveLeftPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Status Bars (2/3 of space)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space evenly
                  mainAxisSize: MainAxisSize.min, // Use minimum space needed
                  children: [
                    statusBar('청결', pet.cleanliness, 'assets/mypage/status/gauaze_bar.svg'),
                    statusBar('행복', pet.happiness, 'assets/mypage/status/gauaze_bar(2).svg'),
                    statusBar('배고픔', 100 - pet.hunger, 'assets/mypage/status/gauaze_bar(3).svg'),
                  ],
                ),
              ),
              
              SizedBox(width: screenSize.width * 0.04),
              
              // Right side: Level Gauge (1/3 of space)
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight, // Constrain to prevent overflow
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Use SVG for level status gauge
                          
                          
                              // 1. SVG Image with controlled size
    // Wrapped SvgPicture in a SizedBox for more explicit size control.
    SizedBox(
      width: metrics.levelGaugeWidth,
      height: metrics.levelGaugeHeight,
      child: SvgPicture.asset(
        'assets/mypage/status/level_status.svg',
        fit: BoxFit.contain,
      ),
    ),
                          
                          // SvgPicture.asset(
                          //   'assets/mypage/status/level_status.svg',
                          //   width: metrics.levelGaugeWidth,
                          //   height: metrics.levelGaugeHeight,
                          //   fit: BoxFit.contain,
                          // ),

                          // XP progress overlay
                          Positioned(
                            bottom: metrics.xpBarBottom,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                width: metrics.xpBarWidth,
                                height: (pet.xpPercent * metrics.xpBarMaxHeight).clamp(0.0, metrics.xpBarMaxHeight),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color(0xFF5F37CF),
                                      const Color(0xFF8B6FE8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Level text positioned at bottom
                          Positioned(
                            // bottom: isTablet ? 8 : 6,
                            child: Text(
                              'LV.${pet.level}', 
                                    textAlign: TextAlign.center, // This ensures the text itself is centered if it wraps
                              style: TextStyle(
                                fontFamily: 'DungGeunMo', 
                                color: Colors.white,
                                fontSize: metrics.levelFontSize,
                                fontWeight: FontWeight.bold,
                                height: 1.0, // Constrain text height
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 2.0,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right padding for balance
              SizedBox(width: responsiveLeftPadding * 0.5), // Smaller right padding
            ],
          ),
        );
      },
    );
  }
}
