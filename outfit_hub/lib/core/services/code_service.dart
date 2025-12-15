import 'api_service.dart';

class CodeService {
  static Future<List<Map<String, dynamic>>> getCategories({required String token}) async {
    try {
      print('[CodeService] getCategories called with token: ${token.isEmpty ? "empty" : "provided"}');
      final res = await ApiService.get('/codes/categories', token: token, debug: true);
      print('[CodeService] getCategories response type: ${res.runtimeType}');
      print('[CodeService] getCategories response: $res');
      final result = _normalizeList(res);
      print('[CodeService] getCategories normalized: ${result.length} items');
      return result;
    } catch (e, stackTrace) {
      print('[CodeService] getCategories error: $e');
      print('[CodeService] stackTrace: $stackTrace');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getColors({required String token}) async {
    final res = await ApiService.get('/codes/colors', token: token);
    return _normalizeList(res);
  }

  static Future<List<Map<String, dynamic>>> getMaterials({required String token}) async {
    final res = await ApiService.get('/codes/materials', token: token);
    return _normalizeList(res);
  }

  static Future<List<Map<String, dynamic>>> getSeasons({required String token}) async {
    final res = await ApiService.get('/codes/seasons', token: token);
    return _normalizeList(res);
  }

  static Future<List<Map<String, dynamic>>> getStyles({required String token}) async {
    final res = await ApiService.get('/codes/styles', token: token);
    return _normalizeList(res);
  }

  static Future<List<Map<String, dynamic>>> getTypes({required String token}) async {
    final res = await ApiService.get('/codes/types', token: token);
    return _normalizeList(res);
  }

  /// Normalize backend responses into Map<String,dynamic> list
  /// Accepts either List<dynamic> or {data: List<dynamic>} structures.
  static List<Map<String, dynamic>> _normalizeList(dynamic res) {
    final dynamic list = (res is Map && res.containsKey('data')) ? res['data'] : res;
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
