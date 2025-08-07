import 'dart:async';
import 'package:flutter/material.dart';
import '../models/loading_screen_model.dart';
import '../pages/category_selection_page.dart';

/// 로딩 스크린의 비즈니스 로직을 관리하는 Controller 클래스
class LoadingScreenController extends ChangeNotifier {
  final LoadingScreenModel _model = LoadingScreenModel();
  Timer? _loadingTimer;
  BuildContext? _context;
  
  // Model에 대한 접근자
  LoadingScreenModel get model => _model;
  
  /// 컨트롤러 초기화
  void initialize([BuildContext? context]) {
    _context = context;
    _startLoadingProcess();
  }
  
  /// 로딩 프로세스 시작
  void _startLoadingProcess() {
    _model.setLoading(true);
    notifyListeners();
    
    // 3초 후 로딩 완료 (실제 앱에서는 실제 로딩 로직 구현)
    _loadingTimer = Timer(const Duration(seconds: 3), () {
      completeLoading();
    });
  }
  
  /// 로딩 완료 처리
  void completeLoading() {
    _model.completeLoading();
    notifyListeners();
    
    // 다음 화면으로 네비게이션
    if (_context != null && _context!.mounted) {
      Navigator.pushReplacement(
        _context!,
        MaterialPageRoute(
          builder: (context) => const CategorySelectionPage(),
        ),
      );
    }
  }
  
  /// 에러 처리
  void handleError(String errorMessage) {
    _model.setError(errorMessage);
    notifyListeners();
  }
  
  /// 이미지 로드 에러 처리
  Widget handleImageError(BuildContext context, Object error, StackTrace? stackTrace) {
    // 에러 로깅 (실제 앱에서는 로깅 서비스 사용)
    debugPrint('Image loading error: $error');
    
    // 폴백 위젯 반환
    return _buildFallbackImage();
  }
  
  /// 폴백 이미지 위젯 빌드
  Widget _buildFallbackImage() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(90),
      ),
      child: const Icon(
        Icons.person,
        size: 80,
        color: Colors.white,
      ),
    );
  }
  
  /// 리소스 정리
  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
}