import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 필터 태그 바
/// ============================================

class FilterTagsBar extends StatelessWidget {
  final List<String> filterSeasons;
  final List<String> filterStyles;
  final List<String> filterColors;
  final Function(String type, String value) onRemoveFilter;
  final VoidCallback onClearAll;

  const FilterTagsBar({
    super.key,
    required this.filterSeasons,
    required this.filterStyles,
    required this.filterColors,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.cardBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...filterSeasons.map((s) => _buildFilterChip(s, 'season')),
            ...filterStyles.map((s) => _buildFilterChip(s, 'style')),
            ...filterColors.map((c) => _buildFilterChip(c, 'color')),
            // 전체 삭제 버튼
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              onPressed: onClearAll,
              child: const Text(
                '전체 삭제',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String type) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onRemoveFilter(type, value),
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
