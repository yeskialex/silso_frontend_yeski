import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/loading_screen_model.dart';
import '../controllers/loading_screen_controller.dart';
import '../utils/responsive_utils.dart';

/// 로딩 스크린의 UI를 담당하는 View 클래스
class LoadingScreenView extends StatefulWidget {
  const LoadingScreenView({super.key});

  @override
  State<LoadingScreenView> createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView> {
  late LoadingScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoadingScreenController();
    _controller.addListener(_onControllerUpdate);
    
    // Initialize with context after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(context);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        // UI 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            width: AppTheme.getContainerWidth(context),
            height: AppTheme.getContainerHeight(context),
            decoration: _buildContainerDecoration(),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildWelcomeText(context, constraints),
                  _buildCharacterImage(context, constraints),
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 컨테이너 데코레이션 빌드
  ShapeDecoration _buildContainerDecoration() {
    return ShapeDecoration(
      color: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: AppTheme.primaryColor,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  /// 환영 텍스트 위젯 빌드 - 반응형 적용
  Widget _buildWelcomeText(BuildContext context, BoxConstraints constraints) {
    final widthRatio = ResponsiveUtils.getWidthRatio(context);
    final leftPosition = (AppTheme.welcomeTextLeft * widthRatio).clamp(8.0, constraints.maxWidth * 0.8);
    final topPosition = (AppTheme.welcomeTextTop * widthRatio).clamp(8.0, constraints.maxHeight * 0.3);
    
    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: SizedBox(
        width: constraints.maxWidth - leftPosition - 16,
        child: SafeText(
          LoadingScreenModel.welcomeMessage,
          style: AppTheme.welcomeTextStyle.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context: context,
              baseSize: 24,
              minSize: 18,
              maxSize: 28,
            ),
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  /// 캐릭터 이미지 위젯 빌드 - 반응형 적용
  Widget _buildCharacterImage(BuildContext context, BoxConstraints constraints) {
    final widthRatio = ResponsiveUtils.getWidthRatio(context);
    final imageSize = (AppTheme.characterImageSize * widthRatio).clamp(120.0, constraints.maxWidth * 0.4);
    final rightPosition = (AppTheme.characterImageRight * widthRatio).clamp(8.0, constraints.maxWidth * 0.1);
    final bottomPosition = (AppTheme.characterImageBottom * widthRatio).clamp(8.0, constraints.maxHeight * 0.2);
    
    return Positioned(
      right: rightPosition,
      bottom: bottomPosition,
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: Image.asset(
          LoadingScreenModel.characterImagePath,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
          errorBuilder: _controller.handleImageError,
        ),
      ),
    );
  }

  /// 로딩 인디케이터 위젯 빌드
  Widget _buildLoadingIndicator() {
    if (!_controller.model.isLoading) {
      return const SizedBox.shrink();
    }

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 3,
      ),
    );
  }
}