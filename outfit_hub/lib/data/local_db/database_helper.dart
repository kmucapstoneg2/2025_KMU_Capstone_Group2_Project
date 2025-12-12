import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_schema.dart';

/// ============================================
/// 데이터베이스 헬퍼 (싱글톤)
/// ============================================

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseSchema.databaseName);

    return await openDatabase(
      path,
      version: DatabaseSchema.version,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    for (final statement in DatabaseSchema.allCreateStatements) {
      await db.execute(statement);
    }

    await _insertInitialCodeData(db);
    await _insertDefaultUser(db);
  }

  Future<void> _insertInitialCodeData(Database db) async {
    final categories = [
      {'category_id': 'cat_001', 'category_name': '상의'},
      {'category_id': 'cat_002', 'category_name': '하의'},
      {'category_id': 'cat_003', 'category_name': '아우터'},
      {'category_id': 'cat_004', 'category_name': '원피스'},
      {'category_id': 'cat_005', 'category_name': '신발'},
    ];
    for (final category in categories) {
      await db.insert('category_code', category);
    }

    final colors = [
      {'color_id': 'col_001', 'color_name': '화이트', 'hex_code': '#FFFFFF'},
      {'color_id': 'col_002', 'color_name': '블랙', 'hex_code': '#000000'},
      {'color_id': 'col_003', 'color_name': '블루', 'hex_code': '#0000FF'},
      {'color_id': 'col_004', 'color_name': '네이비', 'hex_code': '#000080'},
      {'color_id': 'col_005', 'color_name': '핑크', 'hex_code': '#FFC0CB'},
      {'color_id': 'col_006', 'color_name': '레드', 'hex_code': '#FF0000'},
      {'color_id': 'col_007', 'color_name': '퍼플', 'hex_code': '#800080'},
      {'color_id': 'col_008', 'color_name': '베이지', 'hex_code': '#F5F5DC'},
    ];
    for (final color in colors) {
      await db.insert('color_code', color);
    }

    final materials = [
      {'material_id': 'mat_001', 'material_name': '면'},
      {'material_id': 'mat_002', 'material_name': '니트'},
      {'material_id': 'mat_003', 'material_name': '데님'},
      {'material_id': 'mat_004', 'material_name': '폴리'},
      {'material_id': 'mat_005', 'material_name': '린넨'},
      {'material_id': 'mat_006', 'material_name': '패딩'},
      {'material_id': 'mat_007', 'material_name': '스웨이드'},
      {'material_id': 'mat_008', 'material_name': '레더'},
    ];
    for (final material in materials) {
      await db.insert('material_code', material);
    }

    final seasons = [
      {'season_id': 'sea_001', 'season_name': '봄'},
      {'season_id': 'sea_002', 'season_name': '여름'},
      {'season_id': 'sea_003', 'season_name': '가을'},
      {'season_id': 'sea_004', 'season_name': '겨울'},
      {'season_id': 'sea_005', 'season_name': '사계절'},
    ];
    for (final season in seasons) {
      await db.insert('season_code', season);
    }

    final styles = [
      {'style_id': 'sty_001', 'style_name': '포멀'},
      {'style_id': 'sty_002', 'style_name': '캐주얼'},
      {'style_id': 'sty_003', 'style_name': '데일리'},
      {'style_id': 'sty_004', 'style_name': '스트릿'},
      {'style_id': 'sty_005', 'style_name': '러블리'},
      {'style_id': 'sty_006', 'style_name': '미니멀'},
    ];
    for (final style in styles) {
      await db.insert('style_code', style);
    }

    final types = [
      {'type_id': 'typ_001', 'type_name': '셔츠'},
      {'type_id': 'typ_002', 'type_name': '티셔츠'},
      {'type_id': 'typ_003', 'type_name': '맨투맨'},
      {'type_id': 'typ_004', 'type_name': '후드'},
      {'type_id': 'typ_005', 'type_name': '바지'},
      {'type_id': 'typ_006', 'type_name': '치마'},
      {'type_id': 'typ_007', 'type_name': '반바지'},
      {'type_id': 'typ_008', 'type_name': '패딩'},
      {'type_id': 'typ_009', 'type_name': '자켓'},
      {'type_id': 'typ_010', 'type_name': '원피스'},
      {'type_id': 'typ_011', 'type_name': '스니커즈'},
      {'type_id': 'typ_012', 'type_name': '구두'},
      {'type_id': 'typ_013', 'type_name': '부츠'},
    ];
    for (final type in types) {
      await db.insert('type_code', type);
    }
  }

  Future<void> _insertDefaultUser(Database db) async {
    try {
      await db.insert(
        'user_table',
        {
          'user_id': 'user_default',
          'username': '사용자',
          'email': 'user@example.com',
          'password_hash': 'hash',
          'profile_image_url': null,
          'region': '서울',
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('기본 사용자 생성 오류: $e');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseSchema.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    
    try {
      await db.delete('community_interactions');
      await db.delete('wishlist');
      await db.delete('outfit_combination');
      await db.delete('schedule_table');
      await db.delete('clothes_table');
      await db.delete('weather');
      
      print('모든 데이터 삭제 완료');
    } catch (e) {
      print('데이터 삭제 오류: $e');
      rethrow;
    }
  }
}
