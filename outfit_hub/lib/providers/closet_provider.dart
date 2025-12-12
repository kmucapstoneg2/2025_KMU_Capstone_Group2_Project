import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';

/// ============================================
/// 옷장 Provider
/// ============================================

class ClosetProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _clothes = [];
  List<Map<String, dynamic>> _wishlistClothes = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _colors = [];
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _styles = [];
  List<Map<String, dynamic>> _types = [];

  List<Map<String, dynamic>> get clothes => _clothes;
  List<Map<String, dynamic>> get wishlistClothes => _wishlistClothes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _clothes.length;

  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get colors => _colors;
  List<Map<String, dynamic>> get materials => _materials;
  List<Map<String, dynamic>> get seasons => _seasons;
  List<Map<String, dynamic>> get styles => _styles;
  List<Map<String, dynamic>> get types => _types;

  Future<void> init() async {
    await loadCodeTables();
    await loadClothes();
  }

  Future<void> loadCodeTables() async {
    try {
      _categories = await Storage.getCategories();
      _colors = await Storage.getColors();
      _materials = await Storage.getMaterials();
      _seasons = await Storage.getSeasons();
      _styles = await Storage.getStyles();
      _types = await Storage.getTypes();
      notifyListeners();
    } catch (e) {
      print('코드 테이블 로드 실패: $e');
    }
  }

  Future<void> loadClothes({String? categoryId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clothes = await Storage.getClothes(categoryId: categoryId);
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      throw StorageException('옷 목록을 불러오는데 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWishlist() async {
    try {
      _wishlistClothes = await Storage.getWishlistClothes();
      notifyListeners();
    } catch (e) {
      print('위시리스트 로드 실패: $e');
    }
  }

  Future<String> addCloth({
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
    try {
      final clothId = await Storage.addCloth(
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

      return clothId;
    } catch (e) {
      throw StorageException('옷 추가에 실패했습니다');
    }
  }

  Future<void> updateCloth(
    String clothId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await Storage.updateCloth(clothId, updates);
      await loadClothes();
    } catch (e) {
      throw StorageException('옷 수정에 실패했습니다');
    }
  }

  Future<void> deleteCloth(String clothId) async {
    try {
      await Storage.deleteCloth(clothId);
      _clothes.removeWhere((c) => c['cloth_id'] == clothId);
      _wishlistClothes.removeWhere((c) => c['cloth_id'] == clothId);
      notifyListeners();
    } catch (e) {
      throw StorageException('옷 삭제에 실패했습니다');
    }
  }

  List<Map<String, dynamic>> getClothesByCategory(String categoryName) {
    if (categoryName == '전체') return _clothes;

    return _clothes.where((cloth) {
      return cloth['category_name'] == categoryName;
    }).toList();
  }

  String? getCodeId(String codeName, String codeType) {
    List<Map<String, dynamic>> codeList;

    switch (codeType) {
      case 'season':
        codeList = _seasons;
        break;
      case 'style':
        codeList = _styles;
        break;
      case 'type':
        codeList = _types;
        break;
      case 'color':
        codeList = _colors;
        break;
      case 'material':
        codeList = _materials;
        break;
      case 'category':
        codeList = _categories;
        break;
      default:
        return null;
    }

    final code = codeList.firstWhere(
      (c) => c['${codeType}_name'] == codeName,
      orElse: () => {},
    );

    return code.isNotEmpty ? code['${codeType}_id'] : null;
  }

  String? getCodeName(String codeId, String codeType) {
    List<Map<String, dynamic>> codeList;

    switch (codeType) {
      case 'season':
        codeList = _seasons;
        break;
      case 'style':
        codeList = _styles;
        break;
      case 'type':
        codeList = _types;
        break;
      case 'color':
        codeList = _colors;
        break;
      case 'material':
        codeList = _materials;
        break;
      case 'category':
        codeList = _categories;
        break;
      default:
        return null;
    }

    final code = codeList.firstWhere(
      (c) => c['${codeType}_id'] == codeId,
      orElse: () => {},
    );

    return code.isNotEmpty ? code['${codeType}_name'] : null;
  }
}
