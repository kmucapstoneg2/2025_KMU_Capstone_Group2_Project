/// ============================================
/// 데이터베이스 스키마 정의
/// ============================================

class DatabaseSchema {
  static const int version = 1;
  static const String databaseName = 'outfit_hub.db';

  // ========== 테이블 생성 SQL ==========

  /// 사용자 테이블
  static const String createUserTable = '''
    CREATE TABLE user_table (
      user_id TEXT PRIMARY KEY,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      profile_image_url TEXT,
      region TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  /// 날씨 테이블
  static const String createWeatherTable = '''
    CREATE TABLE weather (
      weather_id TEXT PRIMARY KEY,
      created_at TEXT NOT NULL,
      weather_data TEXT NOT NULL,
      location_key TEXT NOT NULL
    )
  ''';

  /// 옷 테이블
  static const String createClothesTable = '''
    CREATE TABLE clothes_table (
      cloth_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      color_id TEXT NOT NULL,
      material_id TEXT NOT NULL,
      name TEXT NOT NULL,
      season_id TEXT,
      style_id TEXT,
      type_id TEXT,
      purchase_date TEXT,
      price REAL,
      image_url TEXT,
      purchase_link TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES user_table(user_id),
      FOREIGN KEY (category_id) REFERENCES category_code(category_id),
      FOREIGN KEY (color_id) REFERENCES color_code(color_id),
      FOREIGN KEY (material_id) REFERENCES material_code(material_id),
      FOREIGN KEY (season_id) REFERENCES season_code(season_id),
      FOREIGN KEY (style_id) REFERENCES style_code(style_id),
      FOREIGN KEY (type_id) REFERENCES type_code(type_id)
    )
  ''';

  /// 코디 테이블
  static const String createOutfitTable = '''
    CREATE TABLE outfit_combination (
      outfit_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      weather_id TEXT,
      weather_created_at TEXT,
      is_shared INTEGER NOT NULL DEFAULT 0,
      ai_gen_image_url TEXT,
      like_count INTEGER NOT NULL DEFAULT 0,
      cloth_ids TEXT NOT NULL,
      jsonb_data TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES user_table(user_id),
      FOREIGN KEY (weather_id) REFERENCES weather(weather_id)
    )
  ''';

  /// 위시리스트 테이블
  static const String createWishlistTable = '''
    CREATE TABLE wishlist (
      wishlist_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      cloth_id TEXT NOT NULL,
      added_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES user_table(user_id),
      FOREIGN KEY (cloth_id) REFERENCES clothes_table(cloth_id)
    )
  ''';

  /// 커뮤니티 상호작용 테이블
  static const String createCommunityInteractionsTable = '''
    CREATE TABLE community_interactions (
      interaction_id TEXT PRIMARY KEY,
      outfit_id TEXT,
      user_id TEXT,
      parent_comment_id TEXT,
      interaction_type TEXT NOT NULL,
      content TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (outfit_id) REFERENCES outfit_combination(outfit_id),
      FOREIGN KEY (user_id) REFERENCES user_table(user_id)
    )
  ''';

  /// 일정 테이블
  static const String createScheduleTable = '''
    CREATE TABLE schedule_table (
      schedule_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date_key TEXT NOT NULL,
      title TEXT NOT NULL,
      time TEXT,
      location TEXT,
      tags TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES user_table(user_id)
    )
  ''';

  // ========== 코드 테이블 ==========

  /// 카테고리 코드
  static const String createCategoryCodeTable = '''
    CREATE TABLE category_code (
      category_id TEXT PRIMARY KEY,
      category_name TEXT NOT NULL
    )
  ''';

  /// 색상 코드
  static const String createColorCodeTable = '''
    CREATE TABLE color_code (
      color_id TEXT PRIMARY KEY,
      color_name TEXT NOT NULL,
      hex_code TEXT NOT NULL
    )
  ''';

  /// 재질 코드
  static const String createMaterialCodeTable = '''
    CREATE TABLE material_code (
      material_id TEXT PRIMARY KEY,
      material_name TEXT NOT NULL
    )
  ''';

  /// 계절 코드
  static const String createSeasonCodeTable = '''
    CREATE TABLE season_code (
      season_id TEXT PRIMARY KEY,
      season_name TEXT NOT NULL
    )
  ''';

  /// 스타일 코드
  static const String createStyleCodeTable = '''
    CREATE TABLE style_code (
      style_id TEXT PRIMARY KEY,
      style_name TEXT NOT NULL
    )
  ''';

  /// 옷 종류 코드
  static const String createTypeCodeTable = '''
    CREATE TABLE type_code (
      type_id TEXT PRIMARY KEY,
      type_name TEXT NOT NULL
    )
  ''';

  // ========== 인덱스 ==========

  static const String createClothesUserIdIndex = '''
    CREATE INDEX idx_clothes_user_id ON clothes_table(user_id)
  ''';

  static const String createClothesCreatedAtIndex = '''
    CREATE INDEX idx_clothes_created_at ON clothes_table(created_at DESC)
  ''';

  static const String createOutfitUserIdIndex = '''
    CREATE INDEX idx_outfit_user_id ON outfit_combination(user_id)
  ''';

  static const String createOutfitSharedIndex = '''
    CREATE INDEX idx_outfit_shared ON outfit_combination(is_shared, created_at DESC)
  ''';

  static const String createScheduleDateIndex = '''
    CREATE INDEX idx_schedule_date ON schedule_table(date_key)
  ''';

  // ========== 전체 생성 SQL 리스트 ==========

  static List<String> get allCreateStatements => [
        // 코드 테이블 먼저 생성
        createCategoryCodeTable,
        createColorCodeTable,
        createMaterialCodeTable,
        createSeasonCodeTable,
        createStyleCodeTable,
        createTypeCodeTable,

        // 메인 테이블
        createUserTable,
        createWeatherTable,
        createClothesTable,
        createOutfitTable,
        createWishlistTable,
        createCommunityInteractionsTable,
        createScheduleTable,

        // 인덱스
        createClothesUserIdIndex,
        createClothesCreatedAtIndex,
        createOutfitUserIdIndex,
        createOutfitSharedIndex,
        createScheduleDateIndex,
      ];
}
