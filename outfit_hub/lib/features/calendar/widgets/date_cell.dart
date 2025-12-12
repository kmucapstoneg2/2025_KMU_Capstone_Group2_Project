import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../logic/logic.dart';

/// ============================================
/// 날짜 셀
/// ============================================

class DateCell extends StatelessWidget {
  final DateTime date;
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final bool hasData;
  final VoidCallback onTap;

  const DateCell({
    super.key,
    required this.date,
    required this.currentMonth,
    this.selectedDate,
    required this.hasData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSameMonth = CalendarLogic.isSameMonth(date, currentMonth);
    final isToday = CalendarLogic.isToday(date);
    final isSelected = CalendarLogic.isSelectedDate(date, selectedDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primaryLight
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? CupertinoColors.white
                      : isSameMonth
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
            // 데이터 있음 표시
            if (hasData && isSameMonth)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CupertinoColors.white
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
