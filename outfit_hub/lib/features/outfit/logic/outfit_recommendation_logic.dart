import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 코디 추천 비즈니스 로직
/// ============================================

class OutfitRecommendationLogic {
  /// 날씨 기반 코디 추천
  static Future<List<Map<String, dynamic>>> recommendOutfits({
    required Map<String, dynamic> weather,
  }) async {
    try {
      // 모든 옷 가져오기
      final allClothes = await Storage.getClothes();

      // 날씨 정보 추출
      final weatherData = weather['weather_data'] as Map<String, dynamic>;
      final temperature = weatherData['temperature'] as int;

      // 온도에 따른 필터링
      List<Map<String, dynamic>> recommendedClothes;

      if (temperature < 5) {
        // 겨울 (5도 미만)
        recommendedClothes = allClothes.where((cloth) {
          final season = cloth['season_name'] as String?;
          return season == '겨울' || season == '사계절';
        }).toList();
      } else if (temperature < 12) {
        // 가을/봄 (5-12도)
        recommendedClothes = allClothes.where((cloth) {
          final season = cloth['season_name'] as String?;
          return season == '가을' || season == '봄' || season == '사계절';
        }).toList();
      } else if (temperature < 20) {
        // 봄 (12-20도)
        recommendedClothes = allClothes.where((cloth) {
          final season = cloth['season_name'] as String?;
          return season == '봄' || season == '사계절';
        }).toList();
      } else {
        // 여름 (20도 이상)
        recommendedClothes = allClothes.where((cloth) {
          final season = cloth['season_name'] as String?;
          return season == '여름' || season == '사계절';
        }).toList();
      }

      return recommendedClothes;
    } catch (e) {
      throw StorageException('코디 추천에 실패했습니다');
    }
  }

  /// 날씨 조회
  static Future<Map<String, dynamic>?> getTodayWeather() async {
    try {
      return await Storage.getTodayWeather();
    } catch (e) {
      throw StorageException('날씨 정보를 불러오는데 실패했습니다');
    }
  }
}
