/// Model class for category selection data and state management
class CategorySelectionModel {
  // Available categories
  final List<CategoryItem> _availableCategories = [
    CategoryItem(id: 'business', name: '자영업'),
    CategoryItem(id: 'startup', name: '스타트업'),
    CategoryItem(id: 'career_change', name: '이직'),
    CategoryItem(id: 'resignation', name: '퇴사'),
    CategoryItem(id: 'employment', name: '취직'),
    CategoryItem(id: 'study', name: '학업'),
    CategoryItem(id: 'contest', name: '공모전'),
    CategoryItem(id: 'mental_care', name: '멘탈케어'),
    CategoryItem(id: 'relationships', name: '인간관계'),
    CategoryItem(id: 'daily_life', name: '일상'),
    CategoryItem(id: 'humor', name: '유머'),
    CategoryItem(id: 'health', name: '건강'),
  ];

  // Currently selected categories
  final Set<String> _selectedCategoryIds = <String>{};

  // Getters
  List<CategoryItem> get availableCategories => List.unmodifiable(_availableCategories);
  Set<String> get selectedCategoryIds => Set.unmodifiable(_selectedCategoryIds);
  List<CategoryItem> get selectedCategories => _availableCategories
      .where((category) => _selectedCategoryIds.contains(category.id))
      .toList();

  int get selectedCount => _selectedCategoryIds.length;
  bool get hasSelections => _selectedCategoryIds.isNotEmpty;
  bool get isValid => _selectedCategoryIds.isNotEmpty;

  // Selection operations
  bool isSelected(String categoryId) => _selectedCategoryIds.contains(categoryId);

  void selectCategory(String categoryId) {
    if (_availableCategories.any((cat) => cat.id == categoryId)) {
      _selectedCategoryIds.add(categoryId);
    }
  }

  void deselectCategory(String categoryId) {
    _selectedCategoryIds.remove(categoryId);
  }

  void toggleCategory(String categoryId) {
    if (isSelected(categoryId)) {
      deselectCategory(categoryId);
    } else {
      selectCategory(categoryId);
    }
  }

  void clearSelections() {
    _selectedCategoryIds.clear();
  }

  // Utility methods
  CategoryItem? getCategoryById(String id) {
    try {
      return _availableCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  String getSelectionSummary() {
    return '${selectedCount}개 선택됨';
  }

  // Validation
  ValidationResult validateSelection() {
    if (_selectedCategoryIds.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '관심있는 카테고리를 최소 1개 이상 선택해주세요.',
      );
    }
    return ValidationResult(isValid: true);
  }

  // Serialization for data persistence
  Map<String, dynamic> toJson() {
    return {
      'selectedCategoryIds': _selectedCategoryIds.toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    final List<dynamic> ids = json['selectedCategoryIds'] ?? [];
    _selectedCategoryIds.clear();
    _selectedCategoryIds.addAll(ids.cast<String>());
  }
}

/// Individual category item representation
class CategoryItem {
  final String id;
  final String name;
  final String? description;
  final String? iconPath;

  const CategoryItem({
    required this.id,
    required this.name,
    this.description,
    this.iconPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryItem(id: $id, name: $name)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
    };
  }

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
    );
  }
}

/// Validation result for selection state
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// Selection state for UI updates
class SelectionState {
  final int selectedCount;
  final bool isValid;
  final List<CategoryItem> selectedCategories;

  const SelectionState({
    required this.selectedCount,
    required this.isValid,
    required this.selectedCategories,
  });
}