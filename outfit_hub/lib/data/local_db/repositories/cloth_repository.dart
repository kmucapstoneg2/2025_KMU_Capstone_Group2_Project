import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 옷 Repository
/// ============================================

class ClothRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 옷 추가
  Future<String> add({
    required String userId,
    required String categoryId,
    required String colorId,
    required String materialId,
    required String name,
    String? seasonId,
    String? styleId,
    String? typeId,
    DateTime? purchaseDate,
    double? price,
    String? imageUrl,
    String? purchaseLink,
  }) async {
    final db = await _dbHelper.database;
    final clothId = _uuid.v4();

    await db.insert('clothes_table', {
      'cloth_id': clothId,
      'user_id': userId,
      'category_id': categoryId,
      'color_id': colorId,
      'material_id': materialId,
      'name': name,
      'season_id': seasonId,
      'style_id': styleId,
      'type_id': typeId,
      'purchase_date': purchaseDate?.toIso8601String(),
      'price': price,
      'image_url': imageUrl,
      'purchase_link': purchaseLink,
      'created_at': DateTime.now().toIso8601String(),
    });

    return clothId;
  }

  /// 옷 목록 조회 (JOIN으로 코드명 포함)
  Future<List<Map<String, dynamic>>> getList({
    String? userId,
    String? categoryId,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;

    String query = '''
      SELECT 
        c.*,
        cat.category_name,
        col.color_name,
        col.hex_code,
        mat.material_name,
        sea.season_name,
        sty.style_name,
        typ.type_name
      FROM clothes_table c
      LEFT JOIN category_code cat ON c.category_id = cat.category_id
      LEFT JOIN color_code col ON c.color_id = col.color_id
      LEFT JOIN material_code mat ON c.material_id = mat.material_id
      LEFT JOIN season_code sea ON c.season_id = sea.season_id
      LEFT JOIN style_code sty ON c.style_id = sty.style_id
      LEFT JOIN type_code typ ON c.type_id = typ.type_id
    ''';

    final conditions = <String>[];
    final args = <dynamic>[];

    if (userId != null) {
      conditions.add('c.user_id = ?');
      args.add(userId);
    }

    if (categoryId != null) {
      conditions.add('c.category_id = ?');
      args.add(categoryId);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY c.created_at DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    return await db.rawQuery(query, args);
  }

  /// 위시리스트 옷 조회
  Future<List<Map<String, dynamic>>> getWishlistClothes(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        c.*,
        cat.category_name,
        col.color_name,
        col.hex_code,
        mat.material_name,
        sea.season_name,
        sty.style_name,
        typ.type_name
      FROM clothes_table c
      INNER JOIN wishlist w ON c.cloth_id = w.cloth_id
      LEFT JOIN category_code cat ON c.category_id = cat.category_id
      LEFT JOIN color_code col ON c.color_id = col.color_id
      LEFT JOIN material_code mat ON c.material_id = mat.material_id
      LEFT JOIN season_code sea ON c.season_id = sea.season_id
      LEFT JOIN style_code sty ON c.style_id = sty.style_id
      LEFT JOIN type_code typ ON c.type_id = typ.type_id
      WHERE c.user_id = ?
      ORDER BY w.created_at DESC
    ''', [userId]);

    return result;
  }

  /// 옷 상세 조회
  Future<Map<String, dynamic>?> get(String clothId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        c.*,
        cat.category_name,
        col.color_name,
        col.hex_code,
        mat.material_name,
        sea.season_name,
        sty.style_name,
        typ.type_name
      FROM clothes_table c
      LEFT JOIN category_code cat ON c.category_id = cat.category_id
      LEFT JOIN color_code col ON c.color_id = col.color_id
      LEFT JOIN material_code mat ON c.material_id = mat.material_id
      LEFT JOIN season_code sea ON c.season_id = sea.season_id
      LEFT JOIN style_code sty ON c.style_id = sty.style_id
      LEFT JOIN type_code typ ON c.type_id = typ.type_id
      WHERE c.cloth_id = ?
    ''', [clothId]);

    return result.isNotEmpty ? result.first : null;
  }

  /// 옷 수정
  Future<void> update(String clothId, Map<String, dynamic> updates) async {
    final db = await _dbHelper.database;
    await db.update(
      'clothes_table',
      updates,
      where: 'cloth_id = ?',
      whereArgs: [clothId],
    );
  }

  /// 옷 삭제
  Future<void> delete(String clothId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'clothes_table',
      where: 'cloth_id = ?',
      whereArgs: [clothId],
    );
  }

  /// 옷 개수 조회
  Future<int> getCount({String? userId}) async {
    final db = await _dbHelper.database;
    
    String query = 'SELECT COUNT(*) as count FROM clothes_table';
    final args = <dynamic>[];
    
    if (userId != null) {
      query += ' WHERE user_id = ?';
      args.add(userId);
    }
    
    final result = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 카테고리별 옷 개수
  Future<Map<String, int>> getCountByCategory(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        cat.category_name,
        COUNT(*) as count
      FROM clothes_table c
      LEFT JOIN category_code cat ON c.category_id = cat.category_id
      WHERE c.user_id = ?
      GROUP BY c.category_id
    ''', [userId]);

    return Map.fromEntries(
      result.map((row) => MapEntry(
        row['category_name'] as String,
        row['count'] as int,
      )),
    );
  }
}
