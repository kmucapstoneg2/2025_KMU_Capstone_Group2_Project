import 'dart:io';
import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/services/clothes_service.dart';

/// ============================================
/// 옷장 비즈니스 로직 (백엔드 API 기반)
/// ============================================

class ClosetLogic {
  /// 옷 추가 (Backend API)
  static Future<void> addCloth({
    required String token,
    required String categoryName,
    required String colorName,
    required String materialName,
    required String name,
    String? seasonName,
    String? styleName,
    String? itemTypeName,
    File? imageFile,
  }) async {
    try {
      if (imageFile == null) {
        throw Exception('이미지를 선택해주세요');
      }

      final data = {
        'name': name,
        'categoryName': categoryName,
        'colorName': colorName,
        'materialName': materialName,
        if (seasonName != null) 'seasonName': seasonName,
        if (styleName != null) 'styleName': styleName,
        if (itemTypeName != null) 'itemTypeName': itemTypeName,
      };

      await ClothesService.createClothes(
        token: token,
        imageFile: imageFile,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 옷 수정 (Backend API)
  static Future<void> updateCloth({
    required String token,
    required String clothId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await ClothesService.updateClothes(
        token: token,
        clothId: clothId,
        data: updates,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 옷 삭제 (Backend API)
  static Future<void> deleteCloth({
    required String token,
    required String clothId,
  }) async {
    try {
      await ClothesService.deleteClothes(
        token: token,
        clothId: clothId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 위시리스트 토글 (로컬 DB - 임시)
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

  /// 위시리스트 여부 확인 (로컬 DB - 임시)
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
