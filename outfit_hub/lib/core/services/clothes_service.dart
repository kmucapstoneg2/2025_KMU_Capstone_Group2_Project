import 'dart:io';
import 'api_service.dart';

/// ============================================
/// 옷 서비스 - 옷장 관련 API 호출
/// ============================================
/// 
/// 백엔드 엔드포인트:
/// - POST /api/v1/wardrobe/clothes : 옷 등록 (이미지 포함)
/// - GET  /api/v1/wardrobe/clothes : 옷 목록 조회
/// 
/// 사용 예시:
/// ```dart
/// // 옷 목록 조회
/// final response = await ClothesService.getClothesList(token: accessToken);
/// for (var item in response.clothes) {
///   print(item.name);
/// }
/// ```

class ClothesService {
  /// 옷 등록
  /// POST /api/v1/wardrobe/clothes
  static Future<void> createClothes({
    required String token,
    required File imageFile,
    required Map<String, dynamic> data,
  }) async {
    print('[ClothesService] createClothes called');
    print('[ClothesService] data: $data');
    await ApiService.postMultipartFormData(
      '/wardrobe/clothes',
      data: data,
      file: imageFile,
      fileFieldName: 'image',
      token: token,
    );
    print('[ClothesService] Clothes created successfully');
  }

  /// 옷 리스트 조회
  /// GET /api/v1/wardrobe/clothes
  static Future<ClothesListResponse> getClothesList({
    required String token,
  }) async {
    print('[ClothesService] getClothesList called');
    final response = await ApiService.get('/wardrobe/clothes', token: token);
    print('[ClothesService] Raw response: $response');
    return ClothesListResponse.fromJson(response);
  }

  /// 옷 수정
  /// PUT /api/v1/wardrobe/clothes/{clothId}
  static Future<void> updateClothes({
    required String token,
    required String clothId,
    required Map<String, dynamic> data,
  }) async {
    print('[ClothesService] updateClothes called: $clothId');
    print('[ClothesService] Update data: $data');
    await ApiService.putFormData('/wardrobe/clothes/$clothId', data, token: token);
    print('[ClothesService] Clothes updated successfully');
  }

  /// 옷 삭제
  /// DELETE /api/v1/wardrobe/clothes/{clothId}
  static Future<void> deleteClothes({
    required String token,
    required String clothId,
  }) async {
    print('[ClothesService] deleteClothes called: $clothId');
    await ApiService.delete('/wardrobe/clothes/$clothId', token: token);
    print('[ClothesService] Clothes deleted successfully');
  }
}

/// 옷 리스트 응답 모델
class ClothesListResponse {
  final List<ClothesItem> clothes;
  final int totalCount;

  ClothesListResponse({
    required this.clothes,
    required this.totalCount,
  });

  factory ClothesListResponse.fromJson(Map<String, dynamic> json) {
    return ClothesListResponse(
      clothes: (json['clothes'] as List?)
              ?.map((item) => ClothesItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

/// 옷 아이템 모델
/// 백엔드 API에서 반환되는 옷 정보를 담는 클래스
class ClothesItem {
  final String clothId;      // 옷 고유 ID
  final String name;         // 옷 이름
  final String imageUrl;     // 옷 이미지 URL
  final String categoryName; // 카테고리명 (상의, 하의 등)
  final String colorName;    // 색상명
  final String materialName; // 소재명
  final String? styleName;   // 스타일명 (캐주얼, 포멀 등)
  final String? seasonName;  // 계절 (봄, 여름, 가을, 겨울)
  final String? itemTypeName; // 아이템 종류
  final String? createdAt;   // 생성일시

  ClothesItem({
    required this.clothId,
    required this.name,
    required this.imageUrl,
    required this.categoryName,
    required this.colorName,
    required this.materialName,
    this.styleName,
    this.seasonName,
    this.itemTypeName,
    this.createdAt,
  });

  /// JSON 데이터를 ClothesItem 객체로 변환
  factory ClothesItem.fromJson(Map<String, dynamic> json) {
    return ClothesItem(
      clothId: json['clothID']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      colorName: json['colorName'] as String? ?? '',
      materialName: json['materialName'] as String? ?? '',
      styleName: json['styleName'] as String?,
      seasonName: json['seasonName'] as String?,
      itemTypeName: json['itemTypeName'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cloth_id': clothId,
      'name': name,
      'image_url': imageUrl,
      'category_name': categoryName,
      'color_name': colorName,
      'material_name': materialName,
      'style_name': styleName,
      'season_name': seasonName,
      'item_type_name': itemTypeName,
      'created_at': createdAt,
    };
  }
}
