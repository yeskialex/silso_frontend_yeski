/// Splash screen 데이터를 관리하는 Model 클래스
class SplashScreenModel {
  // 스플래시 화면 표시 시간 (5초)
  static const Duration splashDuration = Duration(seconds: 5);
  
  // 앱 로고/브랜드 정보
  static const String appName = '실소';
  static const String appSubtitle = 'SilSo Community';
  static const String appVersion = '1.0.0';
  
  // 로딩 상태
  bool _isLoading = true;
  bool _isCompleted = false;
  
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  
  /// 스플래시 시작
  void startSplash() {
    _isLoading = true;
    _isCompleted = false;
  }
  
  /// 스플래시 완료
  void completeSplash() {
    _isLoading = false;
    _isCompleted = true;
  }
  
  /// 상태 리셋
  void reset() {
    _isLoading = true;
    _isCompleted = false;
  }
}