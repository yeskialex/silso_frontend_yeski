import 'package:flutter/material.dart';

/// Responsive utility class for overflow prevention and adaptive design
class ResponsiveUtils {
  static const double baseWidth = 393.0;
  static const double baseHeight = 852.0;
  
  /// Screen size breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;
  
  /// Get responsive width ratio
  static double getWidthRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / baseWidth).clamp(0.8, 1.5);
  }
  
  /// Get responsive height ratio  
  static double getHeightRatio(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight / baseHeight).clamp(0.8, 1.5);
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Get safe responsive font size
  static double getResponsiveFontSize({
    required BuildContext context,
    required double baseSize,
    double? minSize,
    double? maxSize,
  }) {
    final ratio = getWidthRatio(context);
    final size = baseSize * ratio;
    
    if (minSize != null && size < minSize) return minSize;
    if (maxSize != null && size > maxSize) return maxSize;
    
    return size;
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing({
    required BuildContext context,
    required double baseSpacing,
  }) {
    final ratio = getWidthRatio(context);
    return baseSpacing * ratio;
  }
  
  /// Safe container dimensions with overflow prevention
  static Size getSafeContainerSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    final availableWidth = screenSize.width;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    
    return Size(
      availableWidth * 0.95, // 95% of available width
      availableHeight * 0.9,  // 90% of available height
    );
  }
}

/// Overflow-safe text widget
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  
  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Responsive container with overflow protection
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final bool enableScrolling;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.enableScrolling = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final safeSize = ResponsiveUtils.getSafeContainerSize(context);
    
    Widget content = Container(
      width: width ?? safeSize.width,
      height: height ?? safeSize.height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );
    
    if (enableScrolling) {
      content = SingleChildScrollView(child: content);
    }
    
    return content;
  }
}