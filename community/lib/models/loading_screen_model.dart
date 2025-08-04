/// 로딩 스크린의 데이터를 관리하는 Model 클래스
class LoadingScreenModel {
  // 화면에 표시될 텍스트
  static const String welcomeMessage = '실소 커뮤니티에\n오신 것을 환영합니다!';
  
  // 이미지 경로
  static const String characterImagePath = 'assets/character.png';
  
  // 상태 관리
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  
  // 로딩 상태 변경
  void setLoading(bool loading) {
    _isLoading = loading;
  }
  
  // 에러 상태 설정
  void setError(String? error) {
    _hasError = error != null;
    _errorMessage = error;
  }
  
  // 로딩 완료
  void completeLoading() {
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
  }
}