/// ============================================
/// 가상 피팅 비즈니스 로직
/// ============================================

import '../../../core/services/recommendation_service.dart';

class VirtualFittingLogic {
  /// 선택된 의류들로 가상 피팅 생성
  static Future<String> generateFitting(
    List<Map<String, dynamic>> clothes, {
    required dynamic userImageFile,
  }) async {
    try {
      final clothIds = clothes
          .map((cloth) => cloth['clothID'] as String)
          .toList();

      if (clothIds.isEmpty) {
        throw Exception('선택된 의류가 없습니다');
      }

      final imageUrl = await RecommendationService.generateVirtualFitting(
        clothIds: clothIds,
        userImage: userImageFile,
      );

      return imageUrl as String;
    } catch (e) {
      print('[VirtualFittingLogic] 가상 피팅 생성 오류: $e');
      throw Exception('가상 피팅 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 생성된 가상 피팅을 커뮤니티에 공유
  static Future<String> shareFitting({
    required String imageUrl,
    required String description,
    required List<String> tags,
  }) async {
    try {
      final result = await RecommendationService.uploadOutfitToCommunity(
        imageUrl: imageUrl,
        description: description,
        tags: tags,
      );

      return result['outfitId'] as String;
    } catch (e) {
      print('[VirtualFittingLogic] 공유 오류: $e');
      throw Exception('공유 중 오류가 발생했습니다: $e');
    }
  }
}
