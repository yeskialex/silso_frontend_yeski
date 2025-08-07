import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/splash_screen_model.dart';
import '../controllers/splash_screen_controller.dart';

/// 스플래시 스크린의 UI를 담당하는 View 클래스
class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with TickerProviderStateMixin {
  late SplashScreenController _controller;
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  
  // 추가 안전장치를 위한 변수들
  DateTime? _viewStartTime;
  Timer? _minimumDisplayTimer;

  @override
  void initState() {
    super.initState();
    
    // View 시작 시간 기록
    _viewStartTime = DateTime.now();
    debugPrint('SplashScreenView: initState 시작 - $_viewStartTime');
    
    // 컨트롤러 초기화
    _controller = SplashScreenController();
    _controller.addListener(_onControllerUpdate);
    
    // 최소 표시 시간 보장을 위한 추가 타이머 (안전장치)
    _minimumDisplayTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('SplashScreenView: 최소 5초 타이머 완료');
    });
    
    // 로고 애니메이션 설정 (5초에 맞춰 조정)
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));
    
    // 애니메이션 시작
    _startAnimations();
    
    // 컨트롤러 초기화를 약간 지연시켜 확실한 렌더링 보장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          debugPrint('SplashScreenView: 컨트롤러 초기화');
          _controller.initialize(context);
        }
      });
    });
  }

  @override
  void dispose() {
    debugPrint('SplashScreenView: dispose 호출됨');
    if (_viewStartTime != null) {
      final totalTime = DateTime.now().difference(_viewStartTime!);
      debugPrint('SplashScreenView: 총 생존 시간 ${totalTime.inMilliseconds}ms');
    }
    
    _minimumDisplayTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        // UI 업데이트
      });
    }
  }
  
  void _startAnimations() {
    // 로고 애니메이션 시작
    _logoAnimationController.forward();
    
    // 페이드 애니메이션 시작 (약간의 지연)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackgroundDecoration(),
        child: Stack(
          children: [
            _buildMainContent(),
            _buildBottomContent(),
            // 개발 모드에서 스킵 버튼 (선택사항)
            if (const bool.fromEnvironment('dart.vm.product') != true)
              _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  /// 배경 데코레이션 빌드
  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5F37CF),
          Color(0xFF8A6BD9),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로고 애니메이션
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // 앱 이름 페이드 애니메이션
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  SplashScreenModel.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  SplashScreenModel.appSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Pretendard',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 콘텐츠 빌드
  Widget _buildBottomContent() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 로딩 인디케이터
            if (_controller.model.isLoading)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
            
            // 버전 정보
            Text(
              'v${SplashScreenModel.appVersion}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 개발용 스킵 버튼
  Widget _buildSkipButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TextButton(
          onPressed: () => _controller.skipSplash(),
          child: Text(
            'Skip',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }
}