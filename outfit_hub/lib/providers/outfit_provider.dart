import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';

/// ============================================
/// 코디 Provider
/// ============================================

class OutfitProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _outfits = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get outfits => _outfits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _outfits.length;

  /// 초기화
  Future<void> init() async {
    await loadOutfits();
  }

  /// 코디 목록 로드
  Future<void> loadOutfits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _outfits = await Storage.getOutfits();
    } catch (e) {
      _error = e.toString();
      throw StorageException('코디 목록을 불러오는데 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 최근 코디 조회
  Future<List<Map<String, dynamic>>> getLatestOutfits({int limit = 5}) async {
    try {
      return await Storage.getLatestOutfits(limit: limit);
    } catch (e) {
      throw StorageException('최근 코디를 불러오는데 실패했습니다');
    }
  }

  /// 공유된 코디 조회
  Future<List<Map<String, dynamic>>> getSharedOutfits() async {
    try {
      return await Storage.getSharedOutfits();
    } catch (e) {
      throw StorageException('공유 코디를 불러오는데 실패했습니다');
    }
  }

  /// 코디 저장
  Future<String> saveOutfit({
    required String weatherId,
    required List<String> clothIds,
    required bool isShared,
    String? aiGenImageUrl,
    Map<String, dynamic>? jsonbData,
  }) async {
    try {
      final outfitId = await Storage.saveOutfit(
        weatherId: weatherId,
        clothIds: clothIds,
        isShared: isShared,
        aiGenImageUrl: aiGenImageUrl,
        jsonbData: jsonbData,
      );

      await loadOutfits();
      return outfitId;
    } catch (e) {
      throw StorageException('코디 저장에 실패했습니다');
    }
  }

  /// 코디 삭제
  Future<void> deleteOutfit(String outfitId) async {
    try {
      await Storage.deleteOutfit(outfitId);
      _outfits.removeWhere((o) => o['outfit_id'] == outfitId);
      notifyListeners();
    } catch (e) {
      throw StorageException('코디 삭제에 실패했습니다');
    }
  }

  /// 특정 코디 조회
  Future<Map<String, dynamic>?> getOutfitById(String outfitId) async {
    try {
      return await Storage.getOutfitById(outfitId);
    } catch (e) {
      throw StorageException('코디를 불러오는데 실패했습니다');
    }
  }
}
