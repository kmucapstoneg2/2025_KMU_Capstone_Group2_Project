/// ============================================
/// 코디 추천 서비스
/// ============================================

import 'api_service.dart';

class RecommendationService {
  /// 일정 기반 코디 추천 요청
  static Future<Map<String, dynamic>> getOutfitRecommendation({
    required String date,
    required String time,
    required String location,
    required List<String> tags,
  }) async {
    try {
      print('[RecommendationService] getOutfitRecommendation called');
      print('[RecommendationService] date: $date, time: $time, location: $location, tags: $tags');

      final response = await ApiService.post(
        '/outfits/recommend',
        {
          'date': date,
          'time': time,
          'location': location,
          'tags': tags,
        },
      );

      print('[RecommendationService] Raw response: $response');

      final data = response['data'];
      
      return {
        'success': response['success'] ?? true,
        'data': data ?? response,
      };
    } catch (e) {
      print('[RecommendationService] Error: $e');
      rethrow;
    }
  }

  /// 가상 피팅 이미지 생성
  static Future<Map<String, dynamic>> generateVirtualFitting({
    required List<String> clothIds,
    required dynamic userImage,
  }) async {
    try {
      print('[RecommendationService] generateVirtualFitting called with clothIds: $clothIds');

      // TODO: userImage를 multipart로 전송 구현 필요
      // 현재는 cloth_ids만 전송
      final response = await ApiService.post(
        '/outfits/virtual-fitting',
        {
          'cloth_ids': clothIds,
          // 'user_image': userImage, // 백엔드에서 multipart 구현 후 추가
        },
      );

      print('[RecommendationService] Virtual fitting response: $response');

      return {
        'success': response['success'] ?? true,
        'imageUrl': response['data']?['image_url'] ?? response['data']?['imageUrl'] ?? '',
      };
    } catch (e) {
      print('[RecommendationService] Error: $e');
      rethrow;
    }
  }

  /// 커뮤니티에 코디 업로드
  static Future<Map<String, dynamic>> uploadOutfitToCommunity({
    required String imageUrl,
    required String description,
    required List<String> tags,
  }) async {
    try {
      print('[RecommendationService] uploadOutfitToCommunity called');

      final response = await ApiService.post(
        '/outfits/share',
        {
          'image_url': imageUrl,
          'description': description,
          'tags': tags,
        },
      );

      print('[RecommendationService] Upload response: $response');

      return {
        'success': response['success'] ?? true,
        'outfitId': response['data']?['outfit_id'] ?? response['data']?['outfitId'] ?? '',
      };
    } catch (e) {
      print('[RecommendationService] Error: $e');
      rethrow;
    }
  }
}
