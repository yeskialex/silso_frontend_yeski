import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/loading_screen_model.dart';
import '../controllers/loading_screen_controller.dart';

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
    _controller.initialize();
    _controller.addListener(_onControllerUpdate);
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
      body: Center(
        child: Container(
          width: AppTheme.containerWidth,
          height: AppTheme.containerHeight,
          clipBehavior: Clip.antiAlias,
          decoration: _buildContainerDecoration(),
          child: Stack(
            children: [
              _buildWelcomeText(),
              _buildCharacterImage(),
              _buildLoadingIndicator(),
            ],
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

  /// 환영 텍스트 위젯 빌드
  Widget _buildWelcomeText() {
    return Positioned(
      left: AppTheme.welcomeTextLeft,
      top: AppTheme.welcomeTextTop,
      child: Text(
        LoadingScreenModel.welcomeMessage,
        style: AppTheme.welcomeTextStyle,
      ),
    );
  }

  /// 캐릭터 이미지 위젯 빌드
  Widget _buildCharacterImage() {
    return Positioned(
      right: AppTheme.characterImageRight,
      bottom: AppTheme.characterImageBottom,
      child: Image.asset(
        LoadingScreenModel.characterImagePath,
        width: AppTheme.characterImageSize,
        height: AppTheme.characterImageSize,
        fit: BoxFit.cover,
        errorBuilder: _controller.handleImageError,
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