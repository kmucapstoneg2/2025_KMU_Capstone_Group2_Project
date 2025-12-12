/// ============================================
/// 옷장 필터 로직
/// ============================================

class ClosetFilterLogic {
  /// 필터 적용
  static List<Map<String, dynamic>> applyFilters({
    required List<Map<String, dynamic>> items,
    required String category,
    List<String> filterSeasons = const [],
    List<String> filterStyles = const [],
    List<String> filterColors = const [],
  }) {
    var filtered = items;

    // 카테고리 필터
    if (category != '전체') {
      filtered = filtered.where((item) {
        return item['category_name'] == category;
      }).toList();
    }

    // 계절 필터
    if (filterSeasons.isNotEmpty) {
      filtered = filtered.where((item) {
        final season = item['season_name'];
        return season != null && filterSeasons.contains(season);
      }).toList();
    }

    // 스타일 필터
    if (filterStyles.isNotEmpty) {
      filtered = filtered.where((item) {
        final style = item['style_name'];
        return style != null && filterStyles.contains(style);
      }).toList();
    }

    // 색상 필터
    if (filterColors.isNotEmpty) {
      filtered = filtered.where((item) {
        final color = item['color_name'];
        return color != null && filterColors.contains(color);
      }).toList();
    }

    return filtered;
  }

  /// 활성 필터 여부
  static bool hasActiveFilters({
    List<String> filterSeasons = const [],
    List<String> filterStyles = const [],
    List<String> filterColors = const [],
  }) {
    return filterSeasons.isNotEmpty ||
        filterStyles.isNotEmpty ||
        filterColors.isNotEmpty;
  }

  /// 필터 개수
  static int getFilterCount({
    List<String> filterSeasons = const [],
    List<String> filterStyles = const [],
    List<String> filterColors = const [],
  }) {
    return filterSeasons.length + filterStyles.length + filterColors.length;
  }
}
