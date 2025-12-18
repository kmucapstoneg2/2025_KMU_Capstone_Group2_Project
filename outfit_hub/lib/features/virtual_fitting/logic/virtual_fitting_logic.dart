/// ============================================
/// 가상 피팅 비즈니스 로직
/// ============================================

import 'dart:io';

import '../../../core/services/recommendation_service.dart';

class VirtualFittingLogic {
  /// 선택된 의류들로 가상 피팅 생성
  static Future<String> generateFitting(
    List<Map<String, dynamic>> clothes, {
    required File userImageFile,
    required String token,
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
        token: token,
      );

      if (imageUrl['success'] == true && (imageUrl['imageUrl'] as String).isNotEmpty) {
        return imageUrl['imageUrl'] as String;
      }

      throw Exception('가상 피팅 결과를 불러오지 못했습니다');
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
    required String token,
  }) async {
    try {
      final result = await RecommendationService.uploadOutfitToCommunity(
        imageUrl: imageUrl,
        description: description,
        tags: tags,
        token: token,
      );

      return result['outfitId'] as String;
    } catch (e) {
      print('[VirtualFittingLogic] 공유 오류: $e');
      throw Exception('공유 중 오류가 발생했습니다: $e');
    }
  }
}
