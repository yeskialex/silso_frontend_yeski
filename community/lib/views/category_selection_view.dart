import 'package:flutter/material.dart';
import '../controllers/category_selection_controller.dart';
import '../models/category_selection_model.dart';

/// Pure view component for category selection page
class CategorySelectionView extends StatelessWidget {
  final CategorySelectionController controller;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;

  const CategorySelectionView({
    super.key,
    required this.controller,
    this.onNextPage,
    this.onPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _buildCurrentPage(context),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  /// Build app bar with progress indicator
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: controller.canGoBack ? onPreviousPage : () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  color: const Color(0xFF5F37CF),
                  minHeight: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build current page content based on page index
  Widget _buildCurrentPage(BuildContext context) {
    switch (controller.currentPageIndex) {
      case 0:
        return CategorySelectionPage(controller: controller);
      case 1:
        return PageContent(
          title: controller.getPageTitle(),
          description: controller.getPageDescription(),
          color: Colors.green,
        );
      case 2:
        return PageContent(
          title: controller.getPageTitle(),
          description: controller.getPageDescription(),
          color: Colors.red,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build bottom continue button
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: controller.buttonScaleAnimation ?? const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: controller.canProceed ? 1.0 : 0.98,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: controller.canProceed ? onNextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.canProceed 
                      ? const Color(0xFF5F37CF) 
                      : const Color(0xFFBDBDBD),
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: controller.canProceed ? 2 : 0,
                ),
                child: Text(
                  controller.getButtonText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: controller.canProceed 
                        ? Colors.white 
                        : const Color(0xFFEEEEEE),
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.23,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category selection page specific UI
class CategorySelectionPage extends StatelessWidget {
  final CategorySelectionController controller;

  const CategorySelectionPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseWidth = 393.0;
    final double widthRatio = screenWidth / baseWidth;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * widthRatio),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60 * widthRatio),
            
            // Title
            Text(
              controller.getPageTitle(),
              style: TextStyle(
                color: const Color(0xFF121212),
                fontSize: 24 * widthRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.21,
              ),
            ),
            
            SizedBox(height: 16 * widthRatio),

            // Subtitle
            Text(
              controller.getPageDescription(),
              style: TextStyle(
                color: const Color(0xFFC7C7C7),
                fontSize: 16 * widthRatio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.39,
              ),
            ),

            SizedBox(height: 32 * widthRatio),

            // Selection counter
            if (controller.hasSelections)
              Container(
                margin: EdgeInsets.only(bottom: 16 * widthRatio),
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * widthRatio,
                  vertical: 6 * widthRatio,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5F37CF),
                  borderRadius: BorderRadius.circular(20 * widthRatio),
                ),
                child: Text(
                  controller.getSelectionSummary(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 * widthRatio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Category selection area
            CategoryGridView(
              controller: controller,
              widthRatio: widthRatio,
            ),

            SizedBox(height: 40 * widthRatio),
          ],
        ),
      ),
    );
  }
}

/// Grid view for category chips
class CategoryGridView extends StatelessWidget {
  final CategorySelectionController controller;
  final double widthRatio;

  const CategoryGridView({
    super.key,
    required this.controller,
    required this.widthRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9.27 * widthRatio,
      runSpacing: 12 * widthRatio,
      children: controller.availableCategories.map((category) => 
        CategoryChipWidget(
          category: category,
          isSelected: controller.isCategorySelected(category.id),
          onTap: () => controller.toggleCategory(category.id),
          widthRatio: widthRatio,
        )
      ).toList(),
    );
  }
}

/// Individual category chip widget
class CategoryChipWidget extends StatelessWidget {
  final CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;
  final double widthRatio;

  const CategoryChipWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.widthRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * widthRatio,
          vertical: 10 * widthRatio,
        ),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF5F37CF) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.63 * widthRatio,
              color: isSelected 
                  ? const Color(0xFF5F37CF) 
                  : const Color(0xFFC7C7C7),
            ),
            borderRadius: BorderRadius.circular(16.29 * widthRatio),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : const Color(0xFFC7C7C7),
            fontSize: 16.29 * widthRatio,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
          child: Text(
            category.name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Generic page content widget for other pages
class PageContent extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const PageContent({
    super.key,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Validation error dialog
class ValidationErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const ValidationErrorDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: const TextStyle(
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
    );
  }

  static void show(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => ValidationErrorDialog(
        title: title,
        message: message,
      ),
    );
  }
}