import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 멀티 칩 섹션 (다중 선택)
/// ============================================

class MultiChipSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const MultiChipSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
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
            final isSelected = selectedValues.contains(item);

            return GestureDetector(
              onTap: () {
                final newValues = List<String>.from(selectedValues);
                if (isSelected) {
                  newValues.remove(item);
                } else {
                  newValues.add(item);
                }
                onChanged(newValues);
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
      ],
    );
  }
}
