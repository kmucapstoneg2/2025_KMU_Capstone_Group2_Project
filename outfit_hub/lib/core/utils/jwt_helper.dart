import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  /// JWT가 만료되었는지 확인
  static bool isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  /// JWT 만료일 반환 (DateTime)
  static DateTime? getExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (_) {
      return null;
    }
  }
}
