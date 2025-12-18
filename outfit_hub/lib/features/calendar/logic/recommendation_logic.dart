/// ============================================
/// 코디 추천 비즈니스 로직
/// ============================================

import 'dart:io';

import '../../../core/services/recommendation_service.dart';

class RecommendationLogic {
  /// 일정 기반 코디 추천
  static Future<Map<String, dynamic>> recommendOutfit({
    required String date,
    required String time,
    required String location,
    required List<String> tags,
    required String token,
  }) async {
    try {
      final result = await RecommendationService.getOutfitRecommendation(
        date: date,
        time: time,
        location: location,
        tags: tags,
        token: token,
      );

      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>;
      } else {
        throw Exception('코디 추천을 가져오는데 실패했습니다');
      }
    } catch (e) {
      print('[RecommendationLogic] 코디 추천 오류: $e');
      throw Exception('코디 추천 중 오류가 발생했습니다: $e');
    }
  }

  /// 가상 피팅 생성
  static Future<String> generateVirtualFitting({
    required List<String> clothIds,
    required File userImage,
    required String token,
  }) async {
    try {
      final result = await RecommendationService.generateVirtualFitting(
        clothIds: clothIds,
        userImage: userImage,
        token: token,
      );

      if (result['success'] == true) {
        return result['imageUrl'] as String;
      } else {
        throw Exception('가상 피팅 생성에 실패했습니다');
      }
    } catch (e) {
      print('[RecommendationLogic] 가상 피팅 오류: $e');
      throw Exception('가상 피팅 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 코디를 커뮤니티에 업로드
  static Future<String> shareOutfitToCommunity({
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

      if (result['success'] == true) {
        return result['outfitId'] as String;
      } else {
        throw Exception('코디 업로드에 실패했습니다');
      }
    } catch (e) {
      print('[RecommendationLogic] 코디 업로드 오류: $e');
      throw Exception('코디 업로드 중 오류가 발생했습니다: $e');
    }
  }
}
