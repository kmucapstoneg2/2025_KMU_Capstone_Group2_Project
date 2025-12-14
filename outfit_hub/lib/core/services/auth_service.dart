import 'api_service.dart';

/// ============================================
/// 인증 서비스 - 로그인/회원가입/로그아웃
/// ============================================

class AuthService {
  /// 회원가입
  /// POST /api/v1/auth/signup
  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? region,
  }) async {
    await ApiService.post('/auth/signup', {
      'email': email,
      'password': password,
      'username': username,
      if (region != null) 'region': region,
    });
  }

  /// 로그인
  /// POST /api/v1/auth/login
  /// 응답: accessToken, refreshToken, userId, username
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    return AuthResponse.fromJson(response);
  }
}

/// 인증 응답 모델
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String username;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'username': username,
    };
  }
}
