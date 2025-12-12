import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 카테고리 라벨
/// ============================================

class CategoryLabel extends StatelessWidget {
  final String text;

  const CategoryLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
