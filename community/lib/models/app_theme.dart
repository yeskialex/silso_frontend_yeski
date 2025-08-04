import 'package:flutter/material.dart';

/// 앱의 테마 설정을 관리하는 Model 클래스
class AppTheme {
  // 기본 색상 설정
  static const Color primaryColor = Color(0xFF5F37CF);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color transparentWhite = Colors.white;
  
  // 컨테이너 크기 설정
  static const double containerWidth = 393;
  static const double containerHeight = 852;
  
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