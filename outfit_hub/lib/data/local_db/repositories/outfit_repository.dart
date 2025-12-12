import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 코디 Repository
/// ============================================

class OutfitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 코디 추가
  Future<String> add({
    required String userId,
    String? weatherId,
    DateTime? weatherCreatedAt,
    required List<String> clothIds,
    bool isShared = false,
    String? aiGenImageUrl,
    Map<String, dynamic>? jsonbData,
  }) async {
    final db = await _dbHelper.database;
    final outfitId = _uuid.v4();

    await db.insert('outfit_combination', {
      'outfit_id': outfitId,
      'user_id': userId,
      'weather_id': weatherId,
      'weather_created_at': weatherCreatedAt?.toIso8601String(),
      'is_shared': isShared ? 1 : 0,
      'ai_gen_image_url': aiGenImageUrl,
      'like_count': 0,
      'cloth_ids': jsonEncode(clothIds),
      'jsonb_data': jsonbData != null ? jsonEncode(jsonbData) : null,
      'created_at': DateTime.now().toIso8601String(),
    });

    return outfitId;
  }

  /// 코디 목록 조회
  Future<List<Map<String, dynamic>>> getList({
    String? userId,
    bool? isShared,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;

    String query = 'SELECT * FROM outfit_combination';
    final conditions = <String>[];
    final args = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      args.add(userId);
    }

    if (isShared != null) {
      conditions.add('is_shared = ?');
      args.add(isShared ? 1 : 0);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY created_at DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final result = await db.rawQuery(query, args);

    // JSON 파싱
    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['cloth_ids'] = jsonDecode(row['cloth_ids'] as String);
      if (row['jsonb_data'] != null) {
        map['jsonb_data'] = jsonDecode(row['jsonb_data'] as String);
      }
      map['is_shared'] = (row['is_shared'] as int) == 1;
      return map;
    }).toList();
  }

  /// 코디 상세 조회
  Future<Map<String, dynamic>?> get(String outfitId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'outfit_combination',
      where: 'outfit_id = ?',
      whereArgs: [outfitId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
        final map = Map<String, dynamic>.from(row);
    map['cloth_ids'] = jsonDecode(row['cloth_ids'] as String);
    if (row['jsonb_data'] != null) {
      map['jsonb_data'] = jsonDecode(row['jsonb_data'] as String);
    }
    map['is_shared'] = (row['is_shared'] as int) == 1;
    return map;
  }

  /// 코디 수정
  Future<void> update(String outfitId, Map<String, dynamic> updates) async {
    final db = await _dbHelper.database;

    // cloth_ids가 List면 JSON으로 변환
    if (updates['cloth_ids'] is List) {
      updates['cloth_ids'] = jsonEncode(updates['cloth_ids']);
    }

    // jsonb_data가 Map이면 JSON으로 변환
    if (updates['jsonb_data'] is Map) {
      updates['jsonb_data'] = jsonEncode(updates['jsonb_data']);
    }

    // is_shared가 bool이면 int로 변환
    if (updates['is_shared'] is bool) {
      updates['is_shared'] = updates['is_shared'] ? 1 : 0;
    }

    await db.update(
      'outfit_combination',
      updates,
      where: 'outfit_id = ?',
      whereArgs: [outfitId],
    );
  }

  /// 코디 삭제
  Future<void> delete(String outfitId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'outfit_combination',
      where: 'outfit_id = ?',
      whereArgs: [outfitId],
    );
  }

  /// 코디 개수 조회
  Future<int> getCount({String? userId, bool? isShared}) async {
    final db = await _dbHelper.database;

    String query = 'SELECT COUNT(*) as count FROM outfit_combination';
    final conditions = <String>[];
    final args = <dynamic>[];

    if (userId != null) {
      conditions.add('user_id = ?');
      args.add(userId);
    }

    if (isShared != null) {
      conditions.add('is_shared = ?');
      args.add(isShared ? 1 : 0);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    final result = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 최근 코디 조회
  Future<List<Map<String, dynamic>>> getLatest({
    String? userId,
    int limit = 5,
  }) async {
    return await getList(
      userId: userId,
      limit: limit,
      offset: 0,
    );
  }

  /// 공유된 코디 조회
  Future<List<Map<String, dynamic>>> getShared({int? limit}) async {
    return await getList(
      isShared: true,
      limit: limit,
    );
  }

  /// 좋아요 수 증가
  Future<void> incrementLikeCount(String outfitId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE outfit_combination 
      SET like_count = like_count + 1 
      WHERE outfit_id = ?
    ''', [outfitId]);
  }

  /// 좋아요 수 감소
  Future<void> decrementLikeCount(String outfitId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE outfit_combination 
      SET like_count = CASE 
        WHEN like_count > 0 THEN like_count - 1 
        ELSE 0 
      END 
      WHERE outfit_id = ?
    ''', [outfitId]);
  }
}
