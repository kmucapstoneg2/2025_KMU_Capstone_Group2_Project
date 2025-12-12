import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../logic/logic.dart';

/// ============================================
/// 월 선택기
/// ============================================

class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPrevious,
            child: const Icon(
              CupertinoIcons.chevron_left,
              color: AppColors.primary,
            ),
          ),
          Text(
            CalendarLogic.getMonthString(currentMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onNext,
            child: const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
