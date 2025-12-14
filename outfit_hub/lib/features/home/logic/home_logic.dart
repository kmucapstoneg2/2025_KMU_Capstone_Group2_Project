import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/services/weather_service.dart';

/// ============================================
/// 홈 비즈니스 로직
/// ============================================

class HomeLogic {
  /// 오늘 날씨 조회 (서버 API 호출)
  static Future<WeatherData?> getTodayWeather(String location) async {
    try {
      return await WeatherService.getWeather(location);
    } catch (e) {
      print('날씨 조회 실패: $e');
      return null;
    }
  }

  /// 특정 날짜/지역의 날씨 조회
  static Future<WeatherData?> getWeatherForDate(String location, DateTime date) async {
    try {
      // 현재는 날짜와 관계없이 동일한 API 호출 (추후 확장 가능)
      return await WeatherService.getWeather(location);
    } catch (e) {
      print('날씨 조회 실패: $e');
      return null;
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
