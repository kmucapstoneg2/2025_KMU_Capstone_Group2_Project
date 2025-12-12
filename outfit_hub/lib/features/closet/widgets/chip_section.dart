import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 칩 섹션 (단일 선택)
/// ============================================

class ChipSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onSelect;

  const ChipSection({
    super.key,
    required this.title,
    required this.items,
    this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items.map((item) {
            final isSelected = selectedValue == item;

            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  onSelect(null); // 선택 해제
                } else {
                  onSelect(item);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? CupertinoColors.white
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
