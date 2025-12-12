/// ============================================
/// 날짜 헬퍼
/// ============================================

class DateHelper {
  /// 날짜를 키 형식으로 변환 (YYYY-MM-DD)
  static String toDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 키를 DateTime으로 변환
  static DateTime? fromDateKey(String dateKey) {
    try {
      return DateTime.parse(dateKey);
    } catch (e) {
      return null;
    }
  }

  /// 상대적 날짜 표시 (과거)
  static String formatPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference == 2) {
      return '그저께';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks}주 전';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '${months}개월 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 상대적 날짜 표시 (미래)
  static String formatFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference == 2) {
      return '모레';
    } else if (difference < 7) {
      return '${difference}일 후';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks}주 후';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 날짜 포맷팅 (YYYY년 MM월 DD일)
  static String formatFull(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜 포맷팅 (MM월 DD일)
  static String formatShort(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅 (HH:MM)
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 + 시간 포맷팅
  static String formatDateTime(DateTime date) {
    return '${formatShort(date)} ${formatTime(date)}';
  }

  /// 요일 가져오기
  static String getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 월의 첫날
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 월의 마지막 날
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 월의 일수
  static int getDaysInMonth(DateTime date) {
    return getLastDayOfMonth(date).day;
  }
}
