import 'package:flutter/material.dart';

/// 앱의 테마 설정을 관리하는 Model 클래스
class AppTheme {
  // 기본 색상 설정
  static const Color primaryColor = Color(0xFF5F37CF);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color transparentWhite = Colors.white;
  
  // 반응형 컨테이너 크기 설정 (기준 크기)
  static const double baseContainerWidth = 393;
  static const double baseContainerHeight = 852;
  
  // 반응형 컨테이너 크기 계산 메서드
  static double getContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.95).clamp(300.0, 500.0);
  }
  
  static double getContainerHeight(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    return (availableHeight * 0.9).clamp(400.0, 900.0);
  }
  
  // 호환성을 위한 정적 속성 유지 (deprecated)
  @Deprecated('Use getContainerWidth(context) instead')
  static const double containerWidth = baseContainerWidth;
  @Deprecated('Use getContainerHeight(context) instead')
  static const double containerHeight = baseContainerHeight;
  
  // 이미지 설정
  static const double characterImageSize = 180;
  static const double characterIconSize = 80;
  
  // 텍스트 스타일
  static const TextStyle welcomeTextStyle = TextStyle(
    color: textColor,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.21,
  );
  
  // 위치 설정
  static const double welcomeTextLeft = 16;
  static const double welcomeTextTop = 141;
  static const double characterImageRight = 20;
  static const double characterImageBottom = 100;
}