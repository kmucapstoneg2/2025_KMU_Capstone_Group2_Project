import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 코디 비즈니스 로직
/// ============================================

class CoordiLogic {
  /// 코디 저장
  static Future<String> saveOutfit({
    required String weatherId,
    required List<String> clothIds,
    required bool isShared,
    String? aiGenImageUrl,
    Map<String, dynamic>? jsonbData,
  }) async {
    try {
      return await Storage.saveOutfit(
        weatherId: weatherId,
        clothIds: clothIds,
        isShared: isShared,
        aiGenImageUrl: aiGenImageUrl,
        jsonbData: jsonbData,
      );
    } catch (e) {
      throw StorageException('코디 저장에 실패했습니다');
    }
  }

  /// 옷 목록 조회
  static Future<List<Map<String, dynamic>>> getClothes({
    String? categoryId,
  }) async {
    try {
      return await Storage.getClothes(categoryId: categoryId);
    } catch (e) {
      throw StorageException('옷 목록을 불러오는데 실패했습니다');
    }
  }

  /// 카테고리 목록 조회
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      return await Storage.getCategories();
    } catch (e) {
      throw StorageException('카테고리를 불러오는데 실패했습니다');
    }
  }

  /// 오늘 날씨 조회
  static Future<Map<String, dynamic>?> getTodayWeather() async {
    try {
      return await Storage.getTodayWeather();
    } catch (e) {
      throw StorageException('날씨 정보를 불러오는데 실패했습니다');
    }
  }
}
