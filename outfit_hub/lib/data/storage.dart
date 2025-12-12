import 'local_db/database_helper.dart';
import 'local_db/repositories/repositories.dart';

/// ============================================
/// Storage 통합 인터페이스
/// 기존 코드와의 호환성 유지
/// ============================================

class Storage {
  static final _codeRepo = CodeRepository();
  static final _clothRepo = ClothRepository();
  static final _outfitRepo = OutfitRepository();
  static final _scheduleRepo = ScheduleRepository();
  static final _weatherRepo = WeatherRepository();
  static final _wishlistRepo = WishlistRepository();
  static final _communityRepo = CommunityRepository();
  static final _userRepo = UserRepository();

  static const String defaultUserId = 'user_default';

  /// 초기화
  static Future<void> init() async {
    await DatabaseHelper.instance.database;
  }

  // ========== 코드 테이블 ==========

  static Future<List<Map<String, dynamic>>> getCategories() async {
    return await _codeRepo.getCategories();
  }

  static Future<List<Map<String, dynamic>>> getColors() async {
    return await _codeRepo.getColors();
  }

  static Future<List<Map<String, dynamic>>> getMaterials() async {
    return await _codeRepo.getMaterials();
  }

  static Future<List<Map<String, dynamic>>> getSeasons() async {
    return await _codeRepo.getSeasons();
  }

  static Future<List<Map<String, dynamic>>> getStyles() async {
    return await _codeRepo.getStyles();
  }

  static Future<List<Map<String, dynamic>>> getTypes() async {
    return await _codeRepo.getTypes();
  }

  // ========== 옷 ==========

  static Future<String> addCloth({
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
    return await _clothRepo.add(
      userId: defaultUserId,
      categoryId: categoryId,
      colorId: colorId,
      materialId: materialId,
      name: name,
      seasonId: seasonId,
      styleId: styleId,
      typeId: typeId,
      purchaseDate: purchaseDate,
      price: price,
      imageUrl: imageUrl,
      purchaseLink: purchaseLink,
    );
  }

  static Future<List<Map<String, dynamic>>> getClothes({
    String? categoryId,
  }) async {
    return await _clothRepo.getList(
      userId: defaultUserId,
      categoryId: categoryId,
    );
  }

  static Future<List<Map<String, dynamic>>> getWishlistClothes() async {
    return await _wishlistRepo.getList(userId: defaultUserId);
  }

  static Future<Map<String, dynamic>?> getClothById(String clothId) async {
    return await _clothRepo.get(clothId);
  }

  static Future<void> updateCloth(
    String clothId,
    Map<String, dynamic> updates,
  ) async {
    return await _clothRepo.update(clothId, updates);
  }

  static Future<void> deleteCloth(String clothId) async {
    return await _clothRepo.delete(clothId);
  }

  static Future<int> getTotalClothCount() async {
    return await _clothRepo.getCount(userId: defaultUserId);
  }

  // ========== 코디 ==========

  static Future<String> saveOutfit({
    required String weatherId,
    required List<String> clothIds,
    required bool isShared,
    String? aiGenImageUrl,
    Map<String, dynamic>? jsonbData,
  }) async {
    return await _outfitRepo.add(
      userId: defaultUserId,
      weatherId: weatherId,
      clothIds: clothIds,
      isShared: isShared,
      aiGenImageUrl: aiGenImageUrl,
      jsonbData: jsonbData,
    );
  }

  static Future<List<Map<String, dynamic>>> getOutfits() async {
    return await _outfitRepo.getList(userId: defaultUserId);
  }

  static Future<Map<String, dynamic>?> getOutfitById(String outfitId) async {
    return await _outfitRepo.get(outfitId);
  }

  static Future<void> deleteOutfit(String outfitId) async {
    return await _outfitRepo.delete(outfitId);
  }

  static Future<List<Map<String, dynamic>>> getLatestOutfits({
    int limit = 5,
  }) async {
    return await _outfitRepo.getLatest(
      userId: defaultUserId,
      limit: limit,
    );
  }

  static Future<List<Map<String, dynamic>>> getSharedOutfits() async {
    return await _outfitRepo.getShared();
  }

  static Future<int> getTotalOutfitCount() async {
    return await _outfitRepo.getCount(userId: defaultUserId);
  }

  // ========== 일정 ==========

  static Future<String> addSchedule({
    required String dateKey,
    required String title,
    String? time,
    String? location,
    List<String>? tags,
  }) async {
    return await _scheduleRepo.add(
      userId: defaultUserId,
      dateKey: dateKey,
      title: title,
      time: time,
      location: location,
      tags: tags,
    );
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getSchedules() async {
    return await _scheduleRepo.getListByDate(userId: defaultUserId);
  }

  static Future<List<Map<String, dynamic>>> getSchedulesByDate(
    String dateKey,
  ) async {
    return await _scheduleRepo.getListByDateKey(
      dateKey: dateKey,
      userId: defaultUserId,
    );
  }

  static Future<void> deleteSchedule(String dateKey, int index) async {
    return await _scheduleRepo.deleteByDateAndIndex(
      dateKey: dateKey,
      index: index,
      userId: defaultUserId,
    );
  }

  // ========== 날씨 ==========

  static Future<Map<String, dynamic>?> getTodayWeather() async {
    return await _weatherRepo.getToday();
  }

  static Future<String> addWeather({
    required Map<String, dynamic> weatherData,
    String locationKey = '서울',
  }) async {
    return await _weatherRepo.add(
      weatherData: weatherData,
      locationKey: locationKey,
    );
  }

  // ========== 위시리스트 ==========

  static Future<void> addItemLike(String clothId) async {
    await _wishlistRepo.add(
      userId: defaultUserId,
      clothId: clothId,
    );
  }

  static Future<void> removeItemLike(String clothId) async {
    await _wishlistRepo.deleteByClothId(
      clothId: clothId,
      userId: defaultUserId,
    );
  }

  static Future<bool> isItemLiked(String clothId) async {
    return await _wishlistRepo.isLiked(
      clothId: clothId,
      userId: defaultUserId,
    );
  }

  static Future<List<String>> getLikedItems() async {
    return await _wishlistRepo.getLikedClothIds(userId: defaultUserId);
  }

  // ========== 커뮤니티 ==========

  static Future<void> addLike(String outfitId) async {
    await _communityRepo.addLike(
      outfitId: outfitId,
      userId: defaultUserId,
    );
    await _outfitRepo.incrementLikeCount(outfitId);
  }

  static Future<void> removeLike(String outfitId) async {
    await _communityRepo.removeLike(
      outfitId: outfitId,
      userId: defaultUserId,
    );
    await _outfitRepo.decrementLikeCount(outfitId);
  }

  static Future<bool> isLiked(String outfitId) async {
    return await _communityRepo.isLiked(
      outfitId: outfitId,
      userId: defaultUserId,
    );
  }

  static Future<String> addComment({
    required String outfitId,
    required String content,
    String? parentCommentId,
  }) async {
    return await _communityRepo.addComment(
      outfitId: outfitId,
      userId: defaultUserId,
      content: content,
      parentCommentId: parentCommentId,
    );
  }

  static Future<List<Map<String, dynamic>>> getComments(String outfitId) async {
    return await _communityRepo.getComments(outfitId: outfitId);
  }

  static Future<void> deleteComment(String interactionId) async {
    return await _communityRepo.deleteComment(interactionId);
  }

  // ========== 사용자 ==========

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _userRepo.getCurrent();
  }

  static Future<void> updateUser(Map<String, dynamic> updates) async {
    return await _userRepo.update(defaultUserId, updates);
  }

  // ========== 데이터 관리 ==========

  static Future<void> clearAll() async {
    await DatabaseHelper.instance.clearAllData();
  }
}
