import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../logic/logic.dart';
import 'date_cell.dart';

/// ============================================
/// 캘린더 그리드
/// ============================================

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Map<String, bool> datesWithData;
  final Function(DateTime) onDateSelected;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    required this.datesWithData,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dates = CalendarLogic.generateCalendarDates(currentMonth);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 요일 헤더
          _buildWeekdayHeader(),
          const SizedBox(height: AppSpacing.sm),
          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              if (date == null) {
                return const SizedBox();
              }

              final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final hasData = datesWithData[dateKey] ?? false;

              return DateCell(
                date: date,
                currentMonth: currentMonth,
                selectedDate: selectedDate,
                hasData: hasData,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 요일 헤더
  Widget _buildWeekdayHeader() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
