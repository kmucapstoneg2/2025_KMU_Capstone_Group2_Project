import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/date_helper.dart';

/// ============================================
/// 일정 비즈니스 로직
/// ============================================

class ScheduleLogic {
  /// 일정 추가
  static Future<void> addSchedule({
    required DateTime date,
    required String title,
    String? time,
    String? location,
    List<String>? tags,
  }) async {
    try {
      final dateKey = DateHelper.toDateKey(date);
      await Storage.addSchedule(
        dateKey: dateKey,
        title: title,
        time: time,
        location: location,
        tags: tags,
      );
    } catch (e) {
      throw StorageException('일정 추가에 실패했습니다');
    }
  }

  /// 일정 삭제
  static Future<void> deleteSchedule({
    required DateTime date,
    required int index,
  }) async {
    try {
      final dateKey = DateHelper.toDateKey(date);
      await Storage.deleteSchedule(dateKey, index);
    } catch (e) {
      throw StorageException('일정 삭제에 실패했습니다');
    }
  }

  /// 특정 날짜의 일정 조회
  static Future<List<Map<String, dynamic>>> getSchedulesByDate(
    DateTime date,
  ) async {
    try {
      final dateKey = DateHelper.toDateKey(date);
      return await Storage.getSchedulesByDate(dateKey);
    } catch (e) {
      throw StorageException('일정을 불러오는데 실패했습니다');
    }
  }
}
