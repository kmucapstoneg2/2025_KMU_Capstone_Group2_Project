import 'dart:convert';
import 'dart:io';

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
    required String token,
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
        token: token,
      );

      print('[RecommendationService] Raw response: $response');

      final data = response['data'] as Map<String, dynamic>? ?? {};

      return {
        'success': response['success'] ?? true,
        'data': data,
      };
    } catch (e) {
      print('[RecommendationService] Error: $e');
      rethrow;
    }
  }

  /// 가상 피팅 이미지 생성
  static Future<Map<String, dynamic>> generateVirtualFitting({
    required List<String> clothIds,
    required File userImage,
    required String token,
  }) async {
    try {
      print('[RecommendationService] generateVirtualFitting called with clothIds: $clothIds');

      final response = await ApiService.postMultipartFormData(
        '/outfits/virtual-fitting',
        data: {
          'cloth_ids': jsonEncode(clothIds),
        },
        file: userImage,
        fileFieldName: 'image',
        token: token,
      );

      print('[RecommendationService] Virtual fitting response: $response');

      final data = response['data'] as Map<String, dynamic>? ?? {};

      return {
        'success': response['success'] ?? true,
        'imageUrl': data['image_url'] ?? data['imageUrl'] ?? '',
        'outfitId': data['outfit_id'] ?? data['outfitId'],
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
    required String token,
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
        token: token,
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
