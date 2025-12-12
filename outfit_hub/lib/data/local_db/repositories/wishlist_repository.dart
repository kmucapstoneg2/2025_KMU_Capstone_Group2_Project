import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 위시리스트 Repository
/// ============================================

class WishlistRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 위시리스트 추가
  Future<String> add({
    required String userId,
    required String clothId,
  }) async {
    final db = await _dbHelper.database;
    final wishlistId = _uuid.v4();

    await db.insert('wishlist', {
      'wishlist_id': wishlistId,
      'user_id': userId,
      'cloth_id': clothId,
      'added_at': DateTime.now().toIso8601String(),
    });

    return wishlistId;
  }

  /// 위시리스트 목록 조회 (옷 정보 포함)
  Future<List<Map<String, dynamic>>> getList({String? userId}) async {
        final db = await _dbHelper.database;

    String query = '''
      SELECT 
        w.*,
        c.*,
        cat.category_name,
        col.color_name,
        mat.material_name
      FROM wishlist w
      LEFT JOIN clothes_table c ON w.cloth_id = c.cloth_id
      LEFT JOIN category_code cat ON c.category_id = cat.category_id
      LEFT JOIN color_code col ON c.color_id = col.color_id
      LEFT JOIN material_code mat ON c.material_id = mat.material_id
    ''';
    final args = <dynamic>[];

    if (userId != null) {
      query += ' WHERE w.user_id = ?';
      args.add(userId);
    }

    query += ' ORDER BY w.added_at DESC';

    return await db.rawQuery(query, args);
  }

  /// 좋아요한 옷 ID 목록 조회
  Future<List<String>> getLikedClothIds({String? userId}) async {
    final db = await _dbHelper.database;

    String query = 'SELECT cloth_id FROM wishlist';
    final args = <dynamic>[];

    if (userId != null) {
      query += ' WHERE user_id = ?';
      args.add(userId);
    }

    final result = await db.rawQuery(query, args);
    return result.map((row) => row['cloth_id'] as String).toList();
  }

  /// 특정 옷이 좋아요 되어있는지 확인
  Future<bool> isLiked({
    required String clothId,
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String query = 'SELECT COUNT(*) as count FROM wishlist WHERE cloth_id = ?';
    final args = <dynamic>[clothId];

    if (userId != null) {
      query += ' AND user_id = ?';
      args.add(userId);
    }

    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// 위시리스트 삭제 (옷 ID로)
  Future<void> deleteByClothId({
    required String clothId,
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String where = 'cloth_id = ?';
    final args = <dynamic>[clothId];

    if (userId != null) {
      where += ' AND user_id = ?';
      args.add(userId);
    }

    await db.delete('wishlist', where: where, whereArgs: args);
  }

  /// 위시리스트 삭제 (위시리스트 ID로)
  Future<void> delete(String wishlistId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'wishlist',
      where: 'wishlist_id = ?',
      whereArgs: [wishlistId],
    );
  }

  /// 위시리스트 개수 조회
  Future<int> getCount({String? userId}) async {
    final db = await _dbHelper.database;

    String query = 'SELECT COUNT(*) as count FROM wishlist';
    final args = <dynamic>[];

    if (userId != null) {
      query += ' WHERE user_id = ?';
      args.add(userId);
    }

    final result = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
