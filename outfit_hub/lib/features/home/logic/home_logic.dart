import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/date_helper.dart';

/// ============================================
/// 홈 비즈니스 로직
/// ============================================

class HomeLogic {
  /// 오늘 날씨 조회
  static Future<Map<String, dynamic>?> getTodayWeather() async {
    try {
      return await Storage.getTodayWeather();
    } catch (e) {
      throw StorageException('날씨 정보를 불러오는데 실패했습니다');
    }
  }

  /// 오늘 일정 조회
  static Future<List<Map<String, dynamic>>> getTodaySchedules() async {
    try {
      final today = DateTime.now();
      final dateKey = DateHelper.toDateKey(today);
      return await Storage.getSchedulesByDate(dateKey);
    } catch (e) {
      throw StorageException('일정을 불러오는데 실패했습니다');
    }
  }

  /// 최근 코디 조회
  static Future<List<Map<String, dynamic>>> getRecentOutfits({
    int limit = 3,
  }) async {
    try {
      return await Storage.getLatestOutfits(limit: limit);
    } catch (e) {
      throw StorageException('최근 코디를 불러오는데 실패했습니다');
    }
  }

  /// 통계 조회
  static Future<Map<String, int>> getStats() async {
    try {
      final clothCount = await Storage.getTotalClothCount();
      final outfitCount = await Storage.getTotalOutfitCount();

      return {
        'clothCount': clothCount,
        'outfitCount': outfitCount,
      };
    } catch (e) {
      throw StorageException('통계를 불러오는데 실패했습니다');
    }
  }
}
