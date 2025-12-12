import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 프로필 비즈니스 로직
/// ============================================

class ProfileLogic {
  /// 사용자 정보 조회
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      return await Storage.getCurrentUser();
    } catch (e) {
      throw StorageException('사용자 정보를 불러오는데 실패했습니다');
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

  /// 데이터 초기화
  static Future<void> clearAllData() async {
    try {
      await Storage.clearAll();
    } catch (e) {
      throw StorageException('데이터 초기화에 실패했습니다');
    }
  }
}
