import 'package:flutter/material.dart';
import '../models/category_selection_model.dart';

/// Controller class for category selection business logic
class CategorySelectionController extends ChangeNotifier {
  // Model instance
  final CategorySelectionModel _model = CategorySelectionModel();

  // Multi-page navigation state
  int _currentPageIndex = 0;
  final int _totalPageCount = 3;

  // Animation controllers
  AnimationController? _buttonAnimationController;
  Animation<double>? _buttonScaleAnimation;

  // Getters for model data
  CategorySelectionModel get model => _model;
  List<CategoryItem> get availableCategories => _model.availableCategories;
  Set<String> get selectedCategoryIds => _model.selectedCategoryIds;
  int get selectedCount => _model.selectedCount;
  bool get hasSelections => _model.hasSelections;
  bool get isValid => _model.isValid;

  // Navigation state getters
  int get currentPageIndex => _currentPageIndex;
  int get totalPageCount => _totalPageCount;
  double get progress => (_currentPageIndex + 1) / _totalPageCount;
  bool get canProceed => _currentPageIndex == 0 ? isValid : _currentPageIndex < _totalPageCount - 1;
  bool get canGoBack => _currentPageIndex > 0;

  // Animation getters
  Animation<double>? get buttonScaleAnimation => _buttonScaleAnimation;

  /// Initialize the controller with animation controller
  void initialize(TickerProvider vsync) {
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController!,
      curve: Curves.easeInOut,
    ));
  }

  /// Clean up resources
  @override
  void dispose() {
    _buttonAnimationController?.dispose();
    super.dispose();
  }

  /// Category selection operations
  void toggleCategory(String categoryId) {
    _model.toggleCategory(categoryId);
    _triggerSelectionAnimation();
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _model.selectCategory(categoryId);
    _triggerSelectionAnimation();
    notifyListeners();
  }

  void deselectCategory(String categoryId) {
    _model.deselectCategory(categoryId);
    _triggerSelectionAnimation();
    notifyListeners();
  }

  void clearSelections() {
    _model.clearSelections();
    notifyListeners();
  }

  /// Check if category is selected
  bool isCategorySelected(String categoryId) {
    return _model.isSelected(categoryId);
  }

  /// Get category item by ID
  CategoryItem? getCategoryById(String id) {
    return _model.getCategoryById(id);
  }

  /// Navigation operations
  bool nextPage() {
    if (_currentPageIndex == 0) {
      final validation = validateCurrentPage();
      if (!validation.isValid) {
        return false; // Validation failed
      }
    }

    if (_currentPageIndex < _totalPageCount - 1) {
      _currentPageIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  void goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _totalPageCount) {
      _currentPageIndex = pageIndex;
      notifyListeners();
    }
  }

  /// Validation operations
  ValidationResult validateCurrentPage() {
    switch (_currentPageIndex) {
      case 0:
        return _model.validateSelection();
      default:
        return ValidationResult(isValid: true);
    }
  }

  ValidationResult validateSelection() {
    return _model.validateSelection();
  }

  /// Get selection summary
  String getSelectionSummary() {
    return _model.getSelectionSummary();
  }

  /// Animation operations
  void _triggerSelectionAnimation() {
    _buttonAnimationController?.forward().then((_) {
      _buttonAnimationController?.reverse();
    });
  }

  void triggerButtonAnimation() {
    _triggerSelectionAnimation();
  }

  /// Data persistence operations
  Map<String, dynamic> exportData() {
    return {
      'model': _model.toJson(),
      'currentPageIndex': _currentPageIndex,
    };
  }

  void importData(Map<String, dynamic> data) {
    if (data['model'] != null) {
      _model.fromJson(data['model']);
    }
    if (data['currentPageIndex'] != null) {
      _currentPageIndex = data['currentPageIndex'];
    }
    notifyListeners();
  }

  /// Utility methods for UI
  SelectionState getSelectionState() {
    return SelectionState(
      selectedCount: selectedCount,
      isValid: isValid,
      selectedCategories: _model.selectedCategories,
    );
  }

  /// Reset to initial state
  void reset() {
    _model.clearSelections();
    _currentPageIndex = 0;
    notifyListeners();
  }

  /// Get button text based on current page
  String getButtonText() {
    return _currentPageIndex == _totalPageCount - 1 ? '완료' : '계속하기';
  }

  /// Check if navigation is allowed
  bool canNavigateToNextPage() {
    return canProceed;
  }

  /// Get page title based on current page
  String getPageTitle() {
    switch (_currentPageIndex) {
      case 0:
        return '관심있는 카테고리를\n모두 선택해주세요';
      case 1:
        return '본인인증을 진행해주세요';
      case 2:
        return '회원가입 완료!';
      default:
        return '';
    }
  }

  /// Get page description based on current page
  String getPageDescription() {
    switch (_currentPageIndex) {
      case 0:
        return '내게 꼭 맞는 인사이트를 추천 해드릴게요!';
      case 1:
        return '안전한 서비스 이용을 위해 본인인증이 필요합니다.';
      case 2:
        return '환영합니다! 이제 모든 서비스를 이용하실 수 있습니다.';
      default:
        return '';
    }
  }
}