import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// ============================================
/// 사용자 Repository
/// ============================================

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 현재 사용자 조회 (기본 사용자)
  Future<Map<String, dynamic>?> getCurrent() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'user_table',
      where: 'user_id = ?',
      whereArgs: ['user_default'],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// 사용자 정보 수정
  Future<void> update(String userId, Map<String, dynamic> updates) async {
    final db = await _dbHelper.database;

    await db.update(
      'user_table',
      updates,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// 사용자 조회
  Future<Map<String, dynamic>?> get(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'user_table',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.isNotEmpty ? result.first : null;
  }
}
