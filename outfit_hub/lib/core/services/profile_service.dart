import 'dart:io';
import 'api_service.dart';

/// ============================================
/// 프로필 서비스 - 프로필 조회/수정
/// ============================================

class ProfileService {
  /// 프로필 조회
  /// GET /api/v1/mypage/profile
  static Future<ProfileResponse> getProfile({required String token}) async {
    print('[ProfileService] getProfile called with token: ${token.substring(0, 20)}...');
    final response = await ApiService.get('/mypage/profile', token: token, debug: true);
    print('[ProfileService] Raw response: $response');
    return ProfileResponse.fromJson(response);
  }

  /// 프로필 이미지 업로드 (S3)
  /// POST /api/v1/mypage/profile/image
  static Future<String> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    print('[ProfileService] uploadProfileImage called');
    final response = await ApiService.postMultipart(
      '/mypage/profile/image',
      data: {},
      file: imageFile,
      fileFieldName: 'image',
      token: token,
    );
    print('[ProfileService] Upload response: $response');
    return response['imageUrl'] as String;
  }

  /// 프로필 수정
  /// PUT /api/v1/mypage/profile
  static Future<ProfileResponse> updateProfile({
    required String token,
    String? username,
    String? region,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (region != null) body['region'] = region;
    if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;

    print('[ProfileService] updateProfile called');
    print('[ProfileService] Body: $body');
    
    final response = await ApiService.put('/mypage/profile', body, token: token);
    print('[ProfileService] Update response: $response');
    return ProfileResponse.fromJson(response);
  }
}

/// 프로필 응답 모델
class ProfileResponse {
  final String username;
  final String email;
  final String? region;
  final String? profileImageUrl;
  final String? createdAt;

  ProfileResponse({
    required this.username,
    required this.email,
    this.region,
    this.profileImageUrl,
    this.createdAt,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      username: json['userName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      region: json['region'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'region': region ?? '서울',
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }
}
