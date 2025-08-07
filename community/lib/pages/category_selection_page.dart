import 'package:flutter/material.dart';
import '../controllers/category_selection_controller.dart';
import '../views/category_selection_view.dart';

/// Main page widget implementing MVC pattern for category selection
class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage>
    with TickerProviderStateMixin {
  
  // Controller instance - single source of truth for business logic
  late final CategorySelectionController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with animation support
    _controller = CategorySelectionController();
    _controller.initialize(this);
    
    // Listen to controller changes for UI updates
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // Clean up controller and listeners
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Handle controller state changes
  void _onControllerChanged() {
    // UI will automatically rebuild due to setState calls in controller
    // Additional UI-specific logic can be added here if needed
  }

  /// Handle next page navigation
  void _handleNextPage() {
    // Validate current page before proceeding
    final validation = _controller.validateCurrentPage();
    
    if (!validation.isValid) {
      // Show validation error dialog
      _showValidationError(validation.errorMessage ?? '알 수 없는 오류가 발생했습니다.');
      return;
    }

    // Proceed to next page
    final success = _controller.nextPage();
    
    // Handle completion if on last page
    if (_controller.currentPageIndex == _controller.totalPageCount - 1 && success) {
      _handleCompletion();
    }
  }

  /// Handle previous page navigation
  void _handlePreviousPage() {
    final success = _controller.previousPage();
    if (!success && _controller.currentPageIndex == 0) {
      // Exit the page if at first page and can't go back
      Navigator.of(context).pop();
    }
  }

  /// Handle validation errors
  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '카테고리 선택 필요',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFF5F37CF),
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle process completion
  void _handleCompletion() {
    // Export selected data for potential future use
    _controller.exportData();
    
    // Here you would typically:
    // 1. Save data to persistent storage
    // 2. Send data to API
    // 3. Navigate to next screen
    // 4. Show success message
    
    // For now, show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '선택 완료',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${_controller.selectedCount}개의 카테고리가 선택되었습니다.',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit page
            },
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFF5F37CF),
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to listen to controller changes
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CategorySelectionView(
          controller: _controller,
          onNextPage: _handleNextPage,
          onPreviousPage: _handlePreviousPage,
        );
      },
    );
  }
}

/// Extension for debugging and development
extension CategorySelectionPageDebug on _CategorySelectionPageState {
  /// Debug method to print current state
  void debugPrintState() {
    debugPrint('=== Category Selection State ===');
    debugPrint('Current Page: ${_controller.currentPageIndex}');
    debugPrint('Selected Count: ${_controller.selectedCount}');
    debugPrint('Can Proceed: ${_controller.canProceed}');
    debugPrint('Is Valid: ${_controller.isValid}');
    debugPrint('Selected Categories: ${_controller.selectedCategoryIds}');
    debugPrint('================================');
  }
  
  /// Reset controller state (useful for testing)
  void resetState() {
    _controller.reset();
  }
}