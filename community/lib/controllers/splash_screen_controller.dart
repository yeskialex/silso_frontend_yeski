import 'dart:async';
import 'package:flutter/material.dart';
import '../models/splash_screen_model.dart';
import '../pages/welcome_page.dart';

/// 스플래시 스크린의 비즈니스 로직을 관리하는 Controller 클래스
class SplashScreenController extends ChangeNotifier {
  final SplashScreenModel _model = SplashScreenModel();
  Timer? _splashTimer;
  BuildContext? _context;
  DateTime? _startTime;
  bool _isNavigating = false;
  
  // Model에 대한 접근자
  SplashScreenModel get model => _model;
  
  /// 컨트롤러 초기화
  void initialize([BuildContext? context]) {
    _context = context;
    _startSplashProcess();
  }
  
  /// 스플래시 프로세스 시작
  void _startSplashProcess() {
    _startTime = DateTime.now();
    _model.startSplash();
    notifyListeners();
    
    // 5초 후 스플래시 완료 - 정확한 시간 보장
    _splashTimer = Timer(SplashScreenModel.splashDuration, () {
      _attemptNavigation();
    });
  }
  
  /// 네비게이션 시도 - 최소 5초 보장
  void _attemptNavigation() async {
    if (_isNavigating || _startTime == null) return;
    
    final elapsed = DateTime.now().difference(_startTime!);
    final minDuration = SplashScreenModel.splashDuration;
    
    if (elapsed >= minDuration) {
      // 5초가 경과했으면 즉시 네비게이션
      completeSplash();
    } else {
      // 5초가 되지 않았으면 추가 대기
      final remainingTime = minDuration - elapsed;
      debugPrint('Splash: 추가 대기 시간 ${remainingTime.inMilliseconds}ms');
      
      Timer(remainingTime, () {
        completeSplash();
      });
    }
  }
  
  /// 스플래시 완료 처리
  void completeSplash() {
    if (_isNavigating) return; // 중복 네비게이션 방지
    
    _isNavigating = true;
    _model.completeSplash();
    notifyListeners();
    
    // 최종 시간 체크 로그
    if (_startTime != null) {
      final totalElapsed = DateTime.now().difference(_startTime!);
      debugPrint('Splash: 총 표시 시간 ${totalElapsed.inMilliseconds}ms');
    }
    
    // Welcome 화면으로 네비게이션
    if (_context != null && _context!.mounted) {
      Navigator.of(_context!).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 페이드 인 애니메이션
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  
  /// 스플래시 스킵 (개발용)
  void skipSplash() {
    debugPrint('Splash: Skip 버튼 클릭됨');
    _splashTimer?.cancel();
    
    // Skip할 때도 최소 시간 체크 (개발 모드에서만)
    if (_startTime != null && const bool.fromEnvironment('dart.vm.product') != true) {
      final elapsed = DateTime.now().difference(_startTime!);
      debugPrint('Splash: Skip 시 경과 시간 ${elapsed.inMilliseconds}ms');
    }
    
    completeSplash();
  }
  
  /// 현재 스플래시 표시 시간 가져오기 (디버깅용)
  Duration? get elapsedTime {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }
  
  /// 스플래시가 최소 시간을 만족했는지 확인
  bool get hasMinimumTimeElapsed {
    if (_startTime == null) return false;
    return DateTime.now().difference(_startTime!) >= SplashScreenModel.splashDuration;
  }
  
  /// 리소스 정리
  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }
}