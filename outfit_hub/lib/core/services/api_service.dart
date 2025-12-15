import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// ============================================
/// API 서비스 - 백엔드 서버와의 HTTP 통신 담당
/// ============================================
/// 
/// 주요 기능:
/// - POST/GET/PUT 요청 처리
/// - Multipart 파일 업로드 (옷 이미지 등)
/// - JWT 토큰 기반 인증 헤더 자동 추가
/// - 에러 응답 처리 및 ApiException 변환
/// 
/// 사용 예시:
/// ```dart
/// // 로그인
/// final response = await ApiService.post('/auth/login', {'email': '...', 'password': '...'});
/// 
/// // 인증된 요청
/// final clothes = await ApiService.get('/wardrobe/clothes', token: accessToken);
/// ```

class ApiService {
  // 백엔드 서버 URL
  // TODO: 실제 서버 URL로 변경 필요
  // - iOS 시뮬레이터: localhost
  // - Android 에뮬레이터: 10.0.2.2
  // - 실제 기기: 서버 IP 또는 도메인
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  static final http.Client _client = http.Client();

  /// POST 요청
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  /// PUT 요청
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('[API PUT] $endpoint');
      print('[API PUT Body] $body');
      
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      print('[API PUT Response] ${response.statusCode}: ${response.body}');
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  /// GET 요청
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
    bool debug = false,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await _client.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (debug) {
        print('[API GET] $endpoint');
        print('[API Response] ${response.statusCode}: ${response.body}');
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  /// Multipart POST 요청 (파일 업로드용)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, dynamic> data,
    required File file,
    required String fileFieldName,
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // JSON 데이터 추가
      request.fields['data'] = jsonEncode(data);
      
      // 파일 추가
      request.files.add(await http.MultipartFile.fromPath(
        fileFieldName,
        file.path,
      ));
      
      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  /// 응답 처리
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    } else {
      String message = '요청에 실패했습니다';
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          message = error['message'] ?? error['error'] ?? message;
        }
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}

/// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
