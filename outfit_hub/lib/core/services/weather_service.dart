import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// ============================================
/// 날씨 서비스 - 백엔드 Weather API 통신
/// ============================================

class WeatherService {
  // 날씨 API는 /api/v1 prefix 없이 /weather 직접 호출
  static const String _weatherBaseUrl = 'http://localhost:8080';
  
  static final http.Client _client = http.Client();

  /// 날씨 정보 조회
  /// [location] 지역명 (예: 서울, 부산, 대구 등)
  static Future<WeatherData> getWeather(String location) async {
    try {
      final uri = Uri.parse('$_weatherBaseUrl/weather').replace(
        queryParameters: {'location': location},
      );
      
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw ApiException('날씨 정보를 가져오는데 실패했습니다', response.statusCode);
      }
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('날씨 정보를 가져오는데 실패했습니다: $e', 0);
    }
  }
}

/// 날씨 데이터 모델
class WeatherData {
  final String location;
  final String description;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final bool hasRealTemperature;

  WeatherData({
    required this.location,
    required this.description,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    this.hasRealTemperature = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      description: json['description'] ?? '날씨 정보 없음',
      temperature: (json['temperature'] ?? 0).toDouble(),
      tempMin: (json['tempMin'] ?? 0).toDouble(),
      tempMax: (json['tempMax'] ?? 0).toDouble(),
      hasRealTemperature: json['hasRealTemperature'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'description': description,
      'temperature': temperature,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'hasRealTemperature': hasRealTemperature,
    };
  }
}
