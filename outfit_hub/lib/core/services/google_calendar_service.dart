import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// 구글 캘린더 서비스 - 구글 캘린더 연동 관련
/// ============================================

class GoogleCalendarService {
  static const String _googleLinkedKey = 'google_calendar_linked';
  static const String _googleAccessTokenKey = 'google_access_token';
  static const String _googleRefreshTokenKey = 'google_refresh_token';
  static const String _googleEmailKey = 'google_calendar_email';

  // 백엔드 OAuth2 URL 베이스 (런타임에 계산)
  static String get _backendBaseUrl => ApiService.baseUrl.replaceAll('/api/v1', '');

  /// 구글 캘린더 연동 여부 확인
  static Future<bool> isLinked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_googleLinkedKey) ?? false;
  }

  /// 연동된 구글 이메일 조회
  static Future<String?> getLinkedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleEmailKey);
  }

  /// 구글 OAuth2 인증 URL 생성
  /// 백엔드의 OAuth2 엔드포인트로 리다이렉트
  static String getGoogleAuthUrl() {
    // 백엔드의 Spring Security OAuth2 로그인 엔드포인트 사용
    return '$_backendBaseUrl/oauth2/authorization/google';
  }

  /// 구글 캘린더 연동 완료 처리 (OAuth2 콜백 후)
  static Future<void> completeGoogleLink({
    required String accessToken,
    String? refreshToken,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_googleLinkedKey, true);
    await prefs.setString(_googleAccessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_googleRefreshTokenKey, refreshToken);
    }
    if (email != null) {
      await prefs.setString(_googleEmailKey, email);
    }
  }

  /// 구글 캘린더 연동 해제
  static Future<void> unlinkGoogleCalendar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_googleLinkedKey);
    await prefs.remove(_googleAccessTokenKey);
    await prefs.remove(_googleRefreshTokenKey);
    await prefs.remove(_googleEmailKey);
  }

  /// 구글 캘린더에서 일정 가져오기 (백엔드 API 사용)
  static Future<List<Map<String, dynamic>>> fetchSchedules({
    required String userToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/schedules/fetch-and-save',
        token: userToken,
      );

      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      throw Exception('구글 캘린더 일정을 가져오는데 실패했습니다: $e');
    }
  }

  /// 이번 주 일정 가져오기 (백엔드 DB에서)
  static Future<List<Map<String, dynamic>>> getWeeklySchedules({
    required String userToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/schedules/this-week',
        token: userToken,
      );

      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      throw Exception('이번 주 일정을 가져오는데 실패했습니다: $e');
    }
  }

  /// 구글 캘린더에 일정 추가
  static Future<Map<String, dynamic>> addScheduleToGoogle({
    required String userToken,
    required String title,
    String? description,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await ApiService.post(
        '/schedules/create',
        {
          'summary': title,
          'description': description ?? '',
          'startTime': startTime,
          'endTime': endTime,
        },
        token: userToken,
      );

      return response;
    } catch (e) {
      throw Exception('구글 캘린더에 일정 추가 실패: $e');
    }
  }

  /// 구글 Access Token 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleAccessTokenKey);
  }
}
