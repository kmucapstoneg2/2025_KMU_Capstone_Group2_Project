import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 날씨 Repository
/// ============================================

class WeatherRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 날씨 추가
  Future<String> add({
    required Map<String, dynamic> weatherData,
    required String locationKey,
  }) async {
    final db = await _dbHelper.database;
    final weatherId = _uuid.v4();

    await db.insert('weather', {
      'weather_id': weatherId,
      'created_at': DateTime.now().toIso8601String(),
      'weather_data': jsonEncode(weatherData),
      'location_key': locationKey,
    });

    return weatherId;
  }

  /// 오늘 날씨 조회
  Future<Map<String, dynamic>?> getToday({String locationKey = '서울'}) async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await db.query(
      'weather',
      where: 'location_key = ? AND created_at >= ?',
      whereArgs: [locationKey, startOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final map = Map<String, dynamic>.from(row);
    map['weather_data'] = jsonDecode(row['weather_data'] as String);
    return map;
  }

  /// 날씨 상세 조회
  Future<Map<String, dynamic>?> get(String weatherId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'weather',
      where: 'weather_id = ?',
      whereArgs: [weatherId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final map = Map<String, dynamic>.from(row);
    map['weather_data'] = jsonDecode(row['weather_data'] as String);
    return map;
  }

  /// 날씨 목록 조회
  Future<List<Map<String, dynamic>>> getList({
    String? locationKey,
    int? limit,
  }) async {
    final db = await _dbHelper.database;

    String query = 'SELECT * FROM weather';
    final args = <dynamic>[];

    if (locationKey != null) {
      query += ' WHERE location_key = ?';
      args.add(locationKey);
    }

    query += ' ORDER BY created_at DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
    }

    final result = await db.rawQuery(query, args);

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['weather_data'] = jsonDecode(row['weather_data'] as String);
      return map;
    }).toList();
  }

  /// 날씨 삭제
  Future<void> delete(String weatherId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'weather',
      where: 'weather_id = ?',
      whereArgs: [weatherId],
    );
  }

  /// 오래된 날씨 데이터 삭제 (7일 이상)
  Future<void> deleteOldData({int daysToKeep = 7}) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'weather',
      where: 'created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
}
