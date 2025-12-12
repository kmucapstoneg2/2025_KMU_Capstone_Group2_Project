import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// ============================================
/// 코드 테이블 Repository
/// ============================================

class CodeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 카테고리 목록 조회
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await _dbHelper.database;
    return await db.query('category_code', orderBy: 'category_id');
  }

  /// 색상 목록 조회
  Future<List<Map<String, dynamic>>> getColors() async {
    final db = await _dbHelper.database;
    return await db.query('color_code', orderBy: 'color_id');
  }

  /// 재질 목록 조회
  Future<List<Map<String, dynamic>>> getMaterials() async {
    final db = await _dbHelper.database;
    return await db.query('material_code', orderBy: 'material_id');
  }

  /// 계절 목록 조회
  Future<List<Map<String, dynamic>>> getSeasons() async {
    final db = await _dbHelper.database;
    return await db.query('season_code', orderBy: 'season_id');
  }

  /// 스타일 목록 조회
  Future<List<Map<String, dynamic>>> getStyles() async {
    final db = await _dbHelper.database;
    return await db.query('style_code', orderBy: 'style_id');
  }

  /// 옷 종류 목록 조회
  Future<List<Map<String, dynamic>>> getTypes() async {
    final db = await _dbHelper.database;
    return await db.query('type_code', orderBy: 'type_id');
  }

  /// 카테고리 이름으로 ID 조회
  Future<String?> getCategoryId(String categoryName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'category_code',
      columns: ['category_id'],
      where: 'category_name = ?',
      whereArgs: [categoryName],
    );
    return result.isNotEmpty ? result.first['category_id'] as String : null;
  }

  /// 색상 이름으로 ID 조회
  Future<String?> getColorId(String colorName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'color_code',
      columns: ['color_id'],
      where: 'color_name = ?',
      whereArgs: [colorName],
    );
    return result.isNotEmpty ? result.first['color_id'] as String : null;
  }

  /// 재질 이름으로 ID 조회
  Future<String?> getMaterialId(String materialName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'material_code',
      columns: ['material_id'],
      where: 'material_name = ?',
      whereArgs: [materialName],
    );
    return result.isNotEmpty ? result.first['material_id'] as String : null;
  }

  /// 계절 이름으로 ID 조회
  Future<String?> getSeasonId(String seasonName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'season_code',
      columns: ['season_id'],
      where: 'season_name = ?',
      whereArgs: [seasonName],
    );
    return result.isNotEmpty ? result.first['season_id'] as String : null;
  }

  /// 스타일 이름으로 ID 조회
  Future<String?> getStyleId(String styleName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'style_code',
      columns: ['style_id'],
      where: 'style_name = ?',
      whereArgs: [styleName],
    );
    return result.isNotEmpty ? result.first['style_id'] as String : null;
  }

  /// 옷 종류 이름으로 ID 조회
  Future<String?> getTypeId(String typeName) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'type_code',
      columns: ['type_id'],
      where: 'type_name = ?',
      whereArgs: [typeName],
    );
    return result.isNotEmpty ? result.first['type_id'] as String : null;
  }
}
