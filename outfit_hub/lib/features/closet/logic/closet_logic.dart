import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 옷장 비즈니스 로직
/// ============================================

class ClosetLogic {
  /// 옷 추가
  static Future<String> addCloth({
    required String categoryId,
    required String colorId,
    required String materialId,
    required String name,
    String? seasonId,
    String? styleId,
    String? typeId,
    DateTime? purchaseDate,
    double? price,
    String? imageUrl,
    String? purchaseLink,
  }) async {
    try {
      return await Storage.addCloth(
        categoryId: categoryId,
        colorId: colorId,
        materialId: materialId,
        name: name,
        seasonId: seasonId,
        styleId: styleId,
        typeId: typeId,
        purchaseDate: purchaseDate,
        price: price,
        imageUrl: imageUrl,
        purchaseLink: purchaseLink,
      );
    } catch (e) {
      throw StorageException('옷 추가에 실패했습니다');
    }
  }

  /// 옷 수정
  static Future<void> updateCloth(
    String clothId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await Storage.updateCloth(clothId, updates);
    } catch (e) {
      throw StorageException('옷 수정에 실패했습니다');
    }
  }

  /// 옷 삭제
  static Future<void> deleteCloth(String clothId) async {
    try {
      await Storage.deleteCloth(clothId);
    } catch (e) {
      throw StorageException('옷 삭제에 실패했습니다');
    }
  }

  /// 위시리스트 토글
  static Future<bool> toggleWishlist(String clothId) async {
    try {
      final isLiked = await Storage.isItemLiked(clothId);

      if (isLiked) {
        await Storage.removeItemLike(clothId);
        return false;
      } else {
        await Storage.addItemLike(clothId);
        return true;
      }
    } catch (e) {
      throw StorageException('위시리스트 처리에 실패했습니다');
    }
  }

  /// 위시리스트 여부 확인
  static Future<bool> isLiked(String clothId) async {
    try {
      return await Storage.isItemLiked(clothId);
    } catch (e) {
      return false;
    }
  }

  /// 코드 이름으로 ID 찾기
  static String? findCodeId(
    List<Map<String, dynamic>> codeList,
    String codeName,
    String codeType,
  ) {
    try {
      final code = codeList.firstWhere(
        (c) => c['${codeType}_name'] == codeName,
        orElse: () => {},
      );
      return code.isNotEmpty ? code['${codeType}_id'] : null;
    } catch (e) {
      return null;
    }
  }
}
