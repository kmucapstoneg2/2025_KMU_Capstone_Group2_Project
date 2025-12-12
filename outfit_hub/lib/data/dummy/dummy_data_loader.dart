import '../storage.dart';
import '../../core/utils/date_helper.dart';

/// ============================================
/// 더미 데이터 로더
/// ============================================

class DummyDataLoader {
  /// 더미 데이터 로드
  static Future<void> load() async {
    await _loadWeatherData();
    await _loadClothData();
    await _loadScheduleData();
    await _loadOutfitData();
  }

  /// 더미 날씨 데이터
  static Future<void> _loadWeatherData() async {
    await Storage.addWeather(
      weatherData: {
        'temperature': 22,
        'condition': '맑음',
        'humidity': 60,
      },
    );
  }

  /// 더미 옷 데이터
  static Future<void> _loadClothData() async {
    final categories = await Storage.getCategories();
    final colors = await Storage.getColors();
    final materials = await Storage.getMaterials();
    final seasons = await Storage.getSeasons();
    final styles = await Storage.getStyles();

    if (categories.isEmpty || colors.isEmpty || materials.isEmpty) {
      return;
    }

    // 상의 - 화이트 셔츠
    await Storage.addCloth(
      categoryId: categories[0]['category_id'],
      colorId: colors[0]['color_id'],
      materialId: materials[0]['material_id'],
      name: '화이트 셔츠',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[0]['style_id'] : null,
      price: 49000,
    );

    // 상의 - 블랙 티셔츠
    await Storage.addCloth(
      categoryId: categories[0]['category_id'],
      colorId: colors[1]['color_id'],
      materialId: materials[0]['material_id'],
      name: '블랙 티셔츠',
      seasonId: seasons.isNotEmpty ? seasons[1]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[1]['style_id'] : null,
      price: 29000,
    );

    // 상의 - 네이비 맨투맨
    await Storage.addCloth(
      categoryId: categories[0]['category_id'],
      colorId: colors[3]['color_id'],
      materialId: materials[0]['material_id'],
      name: '네이비 맨투맨',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[2]['style_id'] : null,
      price: 39000,
    );

    // 하의 - 네이비 청바지
    await Storage.addCloth(
      categoryId: categories[1]['category_id'],
      colorId: colors[3]['color_id'],
      materialId: materials[2]['material_id'],
      name: '네이비 청바지',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[1]['style_id'] : null,
      price: 59000,
    );

    // 하의 - 블랙 슬랙스
    await Storage.addCloth(
      categoryId: categories[1]['category_id'],
      colorId: colors[1]['color_id'],
      materialId: materials[3]['material_id'],
      name: '블랙 슬랙스',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[0]['style_id'] : null,
      price: 69000,
    );

    // 아우터 - 블랙 패딩
    await Storage.addCloth(
      categoryId: categories[2]['category_id'],
      colorId: colors[1]['color_id'],
      materialId: materials[5]['material_id'],
      name: '블랙 패딩',
      seasonId: seasons.isNotEmpty ? seasons[3]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[2]['style_id'] : null,
      price: 189000,
    );

    // 아우터 - 베이지 코트
    await Storage.addCloth(
      categoryId: categories[2]['category_id'],
      colorId: colors[7]['color_id'],
      materialId: materials[0]['material_id'],
      name: '베이지 코트',
      seasonId: seasons.isNotEmpty ? seasons[2]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[0]['style_id'] : null,
      price: 229000,
    );

    // 신발 - 화이트 스니커즈
    await Storage.addCloth(
      categoryId: categories[4]['category_id'],
      colorId: colors[0]['color_id'],
      materialId: materials[7]['material_id'],
      name: '화이트 스니커즈',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[1]['style_id'] : null,
      price: 89000,
    );

    // 신발 - 블랙 구두
    await Storage.addCloth(
      categoryId: categories[4]['category_id'],
      colorId: colors[1]['color_id'],
      materialId: materials[7]['material_id'],
      name: '블랙 구두',
      seasonId: seasons.isNotEmpty ? seasons[4]['season_id'] : null,
      styleId: styles.isNotEmpty ? styles[0]['style_id'] : null,
      price: 129000,
    );

        // 원피스
    if (categories.length > 3) {
      await Storage.addCloth(
        categoryId: categories[3]['category_id'],
        colorId: colors[4]['color_id'],
        materialId: materials[0]['material_id'],
        name: '핑크 원피스',
        seasonId: seasons.isNotEmpty ? seasons[1]['season_id'] : null,
        styleId: styles.isNotEmpty ? styles[4]['style_id'] : null,
        price: 79000,
      );
    }
  }

  /// 더미 일정 데이터
  static Future<void> _loadScheduleData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 일정
    final todayKey = DateHelper.toDateKey(today);
    await Storage.addSchedule(
      dateKey: todayKey,
      title: '팀 미팅',
      time: '14:00',
      location: '회의실 A',
      tags: ['업무', '중요'],
    );

    await Storage.addSchedule(
      dateKey: todayKey,
      title: '저녁 약속',
      time: '19:00',
      location: '강남역',
      tags: ['개인'],
    );

    // 내일 일정
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowKey = DateHelper.toDateKey(tomorrow);
    await Storage.addSchedule(
      dateKey: tomorrowKey,
      title: '프로젝트 발표',
      time: '10:00',
      location: '본사',
      tags: ['업무', '발표'],
    );

    // 모레 일정
    final dayAfterTomorrow = today.add(const Duration(days: 2));
    final dayAfterTomorrowKey = DateHelper.toDateKey(dayAfterTomorrow);
    await Storage.addSchedule(
      dateKey: dayAfterTomorrowKey,
      title: '친구 결혼식',
      time: '12:00',
      location: '웨딩홀',
      tags: ['경조사', '포멀'],
    );

    // 3일 후
    final threeDaysLater = today.add(const Duration(days: 3));
    final threeDaysLaterKey = DateHelper.toDateKey(threeDaysLater);
    await Storage.addSchedule(
      dateKey: threeDaysLaterKey,
      title: '헬스장',
      time: '18:00',
      location: '동네 헬스장',
      tags: ['운동'],
    );

    // 일주일 후
    final oneWeekLater = today.add(const Duration(days: 7));
    final oneWeekLaterKey = DateHelper.toDateKey(oneWeekLater);
    await Storage.addSchedule(
      dateKey: oneWeekLaterKey,
      title: '데이트',
      time: '15:00',
      location: '카페',
      tags: ['개인', '데이트'],
    );
  }

  /// 더미 코디 데이터
  static Future<void> _loadOutfitData() async {
    final clothes = await Storage.getClothes();
    final weather = await Storage.getTodayWeather();

    if (clothes.length < 3 || weather == null) {
      return;
    }

    // 코디 1: 캐주얼
    final casualClothIds = clothes
        .where((c) => ['화이트 셔츠', '네이비 청바지', '화이트 스니커즈']
            .contains(c['name']))
        .map((c) => c['cloth_id'] as String)
        .toList();

    if (casualClothIds.length >= 3) {
      await Storage.saveOutfit(
        weatherId: weather['weather_id'],
        clothIds: casualClothIds,
        isShared: true,
        jsonbData: {
          'description': '데일리 캐주얼 룩',
          'style': '캐주얼',
        },
      );
    }

    // 코디 2: 포멀
    final formalClothIds = clothes
        .where((c) => ['화이트 셔츠', '블랙 슬랙스', '블랙 구두']
            .contains(c['name']))
        .map((c) => c['cloth_id'] as String)
        .toList();

    if (formalClothIds.length >= 3) {
      await Storage.saveOutfit(
        weatherId: weather['weather_id'],
        clothIds: formalClothIds,
        isShared: true,
        jsonbData: {
          'description': '비즈니스 포멀 룩',
          'style': '포멀',
        },
      );
    }

    // 코디 3: 겨울
    final winterClothIds = clothes
        .where((c) => ['블랙 티셔츠', '네이비 청바지', '블랙 패딩', '화이트 스니커즈']
            .contains(c['name']))
        .map((c) => c['cloth_id'] as String)
        .toList();

    if (winterClothIds.length >= 3) {
      await Storage.saveOutfit(
        weatherId: weather['weather_id'],
        clothIds: winterClothIds,
        isShared: false,
        jsonbData: {
          'description': '따뜻한 겨울 룩',
          'style': '데일리',
        },
      );
    }
  }
}
