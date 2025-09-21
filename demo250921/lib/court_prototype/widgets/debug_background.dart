import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Background image debugging and alternative widget
class DebugBackground extends StatelessWidget {
  final Widget child;
  final bool showDebugInfo;

  const DebugBackground({
    super.key,
    required this.child,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Alternative background (gradient)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3F3329), // Default background color
                Color(0xFF2D2319), // Slightly darker color
                Color(0xFF3F3329),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // SVG 배경 시도 (use fallback background on error)
        FutureBuilder<void>(
          future: _loadSvgBackground(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                // SVG 로딩 실패 시 패턴 배경 사용
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F3329),
                    image: _createPatternBackground(),
                  ),
                );
              } else {
                // SVG 로딩 성공 시
                return SvgPicture.asset(
                  'assets/background/background.svg',
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Container(
                    color: const Color(0xFF3F3329),
                  ),
                );
              }
            }
            // Default background while loading
            return Container(color: const Color(0xFF3F3329));
          },
        ),

        // Overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),

        // Content
        child,

        // Debug information (optional)
        if (showDebugInfo)
          Positioned(
            top: 100,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Background: SVG with fallback',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _loadSvgBackground() async {
    try {
      // SVG 로딩 테스트
      await Future.delayed(const Duration(milliseconds: 100));
      // 실제로는 SvgPicture.asset의 결과를 확인해야 함
    } catch (e) {
      throw Exception('SVG loading failed: $e');
    }
  }

  DecorationImage? _createPatternBackground() {
    // 패턴 배경 생성 (for SVG replacement)
    return null; // 실제 구현 시 패턴 이미지 추가
  }
}

// 간단한 색상 배경 위젯 (final fallback)
class SimpleColorBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color? overlayColor;

  const SimpleColorBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF3F3329),
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.8),
            backgroundColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: overlayColor != null
          ? Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: overlayColor,
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

// 텍스처 패턴 배경 위젯
class TextureBackground extends StatelessWidget {
  final Widget child;

  const TextureBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3F3329),
        image: DecorationImage(
          image: AssetImage('assets/background/texture_pattern.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        child: child,
      ),
    );
  }
}