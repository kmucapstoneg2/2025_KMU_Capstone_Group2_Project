import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 일정 Repository
/// ============================================

class ScheduleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 일정 추가
  Future<String> add({
    required String userId,
    required String dateKey,
    required String title,
    String? time,
    String? location,
    List<String>? tags,
  }) async {
    final db = await _dbHelper.database;
    final scheduleId = _uuid.v4();

    await db.insert('schedule_table', {
      'schedule_id': scheduleId,
      'user_id': userId,
      'date_key': dateKey,
      'title': title,
      'time': time,
      'location': location,
      'tags': tags != null ? jsonEncode(tags) : null,
      'created_at': DateTime.now().toIso8601String(),
    });

    return scheduleId;
  }

  /// 일정 목록 조회 (날짜별)
  Future<Map<String, List<Map<String, dynamic>>>> getListByDate({
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String query = 'SELECT * FROM schedule_table';
    final args = <dynamic>[];

    if (userId != null) {
      query += ' WHERE user_id = ?';
      args.add(userId);
    }

    query += ' ORDER BY date_key, time';

    final result = await db.rawQuery(query, args);

    // 날짜별로 그룹화
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final row in result) {
      final map = Map<String, dynamic>.from(row);
      if (row['tags'] != null) {
        map['tags'] = jsonDecode(row['tags'] as String);
      }

      final dateKey = row['date_key'] as String;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(map);
    }

    return grouped;
  }

  /// 특정 날짜 일정 조회
  Future<List<Map<String, dynamic>>> getListByDateKey({
    required String dateKey,
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String query = 'SELECT * FROM schedule_table WHERE date_key = ?';
    final args = <dynamic>[dateKey];

    if (userId != null) {
      query += ' AND user_id = ?';
      args.add(userId);
    }

    query += ' ORDER BY time';

    final result = await db.rawQuery(query, args);

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      if (row['tags'] != null) {
        map['tags'] = jsonDecode(row['tags'] as String);
      }
      return map;
    }).toList();
  }

  /// 일정 상세 조회
  Future<Map<String, dynamic>?> get(String scheduleId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'schedule_table',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final map = Map<String, dynamic>.from(row);
    if (row['tags'] != null) {
      map['tags'] = jsonDecode(row['tags'] as String);
    }
    return map;
  }

  /// 일정 수정
  Future<void> update(String scheduleId, Map<String, dynamic> updates) async {
    final db = await _dbHelper.database;

    // tags가 List면 JSON으로 변환
    if (updates['tags'] is List) {
      updates['tags'] = jsonEncode(updates['tags']);
    }

    await db.update(
      'schedule_table',
      updates,
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );
  }

  /// 일정 삭제
  Future<void> delete(String scheduleId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'schedule_table',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );
  }

  /// 특정 날짜의 특정 인덱스 일정 삭제
  Future<void> deleteByDateAndIndex({
    required String dateKey,
    required int index,
    String? userId,
  }) async {
    final schedules = await getListByDateKey(
      dateKey: dateKey,
      userId: userId,
    );

    if (index >= 0 && index < schedules.length) {
      final scheduleId = schedules[index]['schedule_id'] as String;
      await delete(scheduleId);
    }
  }

  /// 날짜 범위 일정 조회
  Future<List<Map<String, dynamic>>> getListByDateRange({
    required String startDate,
    required String endDate,
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String query = '''
      SELECT * FROM schedule_table 
      WHERE date_key BETWEEN ? AND ?
    ''';
    final args = <dynamic>[startDate, endDate];

    if (userId != null) {
      query += ' AND user_id = ?';
      args.add(userId);
    }

    query += ' ORDER BY date_key, time';

    final result = await db.rawQuery(query, args);

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      if (row['tags'] != null) {
        map['tags'] = jsonDecode(row['tags'] as String);
      }
      return map;
    }).toList();
  }
}
