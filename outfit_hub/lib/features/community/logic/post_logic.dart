import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 게시물 비즈니스 로직
/// ============================================

class PostLogic {
  /// 공유된 코디 목록 조회
  static Future<List<Map<String, dynamic>>> getSharedOutfits() async {
    try {
      return await Storage.getSharedOutfits();
    } catch (e) {
      throw StorageException('게시물을 불러오는데 실패했습니다');
    }
  }

  /// 좋아요 토글
  static Future<bool> toggleLike(String outfitId) async {
    try {
      final isLiked = await Storage.isLiked(outfitId);

      if (isLiked) {
        await Storage.removeLike(outfitId);
        return false;
      } else {
        await Storage.addLike(outfitId);
        return true;
      }
    } catch (e) {
      throw StorageException('좋아요 처리에 실패했습니다');
    }
  }

  /// 좋아요 여부 확인
  static Future<bool> isLiked(String outfitId) async {
    try {
      return await Storage.isLiked(outfitId);
    } catch (e) {
      return false;
    }
  }
}
