import '../../../core/utils/date_helper.dart';

/// ============================================
/// 캘린더 비즈니스 로직
/// ============================================

class CalendarLogic {
  /// 월의 모든 날짜 생성 (이전/다음 달 포함)
  static List<DateTime?> generateCalendarDates(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    // 첫 주의 시작 (월요일 기준)
    final startWeekday = firstDay.weekday; // 1(월) ~ 7(일)
    final daysFromPrevMonth = startWeekday - 1;
    
    // 마지막 주의 끝
    final endWeekday = lastDay.weekday;
    final daysFromNextMonth = 7 - endWeekday;
    
    final dates = <DateTime?>[];
    
    // 이전 달 날짜
    for (int i = daysFromPrevMonth; i > 0; i--) {
      dates.add(firstDay.subtract(Duration(days: i)));
    }
    
    // 현재 달 날짜
    for (int i = 0; i < lastDay.day; i++) {
      dates.add(DateTime(month.year, month.month, i + 1));
    }
    
    // 다음 달 날짜
    for (int i = 1; i <= daysFromNextMonth; i++) {
      dates.add(lastDay.add(Duration(days: i)));
    }
    
    return dates;
  }

  /// 날짜가 같은 달인지 확인
  static bool isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  /// 날짜가 오늘인지 확인
  static bool isToday(DateTime date) {
    return DateHelper.isToday(date);
  }

  /// 날짜가 선택된 날짜인지 확인
  static bool isSelectedDate(DateTime date, DateTime? selectedDate) {
    if (selectedDate == null) return false;
    return DateHelper.isSameDay(date, selectedDate);
  }

  /// 이전 달로 이동
  static DateTime getPreviousMonth(DateTime month) {
    return DateTime(month.year, month.month - 1);
  }

  /// 다음 달로 이동
  static DateTime getNextMonth(DateTime month) {
    return DateTime(month.year, month.month + 1);
  }

  /// 월 표시 문자열
  static String getMonthString(DateTime month) {
    return '${month.year}년 ${month.month}월';
  }
}
