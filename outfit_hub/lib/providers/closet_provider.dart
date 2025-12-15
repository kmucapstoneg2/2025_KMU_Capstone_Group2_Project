import 'package:flutter/foundation.dart';
import '../core/services/clothes_service.dart';
import '../core/services/code_service.dart';
import '../data/storage.dart';

/// ============================================
/// 옷장 Provider (백엔드 API 기반)
/// ============================================

class ClosetProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Backend API에서 가져온 옷 리스트
  List<ClothesItem> _backendClothes = [];
  
  // 위시리스트는 로컬에서 관리 (임시)
  List<Map<String, dynamic>> _wishlistClothes = [];

  // 코드 테이블 (로컬 DB 유지)
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _colors = [];
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _styles = [];
  List<Map<String, dynamic>> _types = [];

  List<ClothesItem> get backendClothes => _backendClothes;
  List<Map<String, dynamic>> get wishlistClothes => _wishlistClothes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _backendClothes.length;

  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get colors => _colors;
  List<Map<String, dynamic>> get materials => _materials;
  List<Map<String, dynamic>> get clothes {
    // _backendClothes를 Map으로 변환
    return _backendClothes.map((item) => {
      'clothID': item.clothId,
      'name': item.name,
      'imageUrl': item.imageUrl,
      'categoryName': item.categoryName,
      'colorName': item.colorName,
      'materialName': item.materialName,
      'styleName': item.styleName,
      'seasonName': item.seasonName,
      'itemTypeName': item.itemTypeName,
    }).toList();
  }
  List<Map<String, dynamic>> get seasons => _seasons;
  List<Map<String, dynamic>> get styles => _styles;
  List<Map<String, dynamic>> get types => _types;

  /// 초기화 - 코드 테이블 로드 후, 토큰 있으면 옷 목록도 로드
  Future<void> init() async {
    print('[ClosetProvider] init() called');
    await loadCodeTables(token: '');
    print('[ClosetProvider] init() completed');
  }

  /// 코드 테이블 로드 (백엔드 API 기반 - 공개API, 토큰 불필요)
  /// 동적 로딩: 백엔드에서 항상 가져옴. 실패시 _getDefaultData()에서 동일한 값 사용
  Future<void> loadCodeTables({String? token}) async {
    try {
      print('[ClosetProvider] loadCodeTables 시작');
      _categories = await CodeService.getCategories(token: '');
      print('[ClosetProvider] categories 로드 완료: ${_categories.length}개');
      
      if (_categories.isEmpty) {
        print('[ClosetProvider] categories 가져오기 실패, 기본값 사용');
        _categories = _getDefaultData('categories');
      }
      
      _colors = await CodeService.getColors(token: '');
      print('[ClosetProvider] colors 로드 완료: ${_colors.length}개');
      if (_colors.isEmpty) {
        print('[ClosetProvider] colors 가져오기 실패, 기본값 사용');
        _colors = _getDefaultData('colors');
      }
      
      _materials = await CodeService.getMaterials(token: '');
      print('[ClosetProvider] materials 로드 완료: ${_materials.length}개');
      if (_materials.isEmpty) {
        print('[ClosetProvider] materials 가져오기 실패, 기본값 사용');
        _materials = _getDefaultData('materials');
      }
      
      _seasons = await CodeService.getSeasons(token: '');
      print('[ClosetProvider] seasons 로드 완료: ${_seasons.length}개');
      if (_seasons.isEmpty) {
        print('[ClosetProvider] seasons 가져오기 실패, 기본값 사용');
        _seasons = _getDefaultData('seasons');
      }
      
      _styles = await CodeService.getStyles(token: '');
      print('[ClosetProvider] styles 로드 완료: ${_styles.length}개');
      if (_styles.isEmpty) {
        print('[ClosetProvider] styles 가져오기 실패, 기본값 사용');
        _styles = _getDefaultData('styles');
      }
      
      _types = await CodeService.getTypes(token: '');
      print('[ClosetProvider] types 로드 완료: ${_types.length}개');
      if (_types.isEmpty) {
        print('[ClosetProvider] types 가져오기 실패, 기본값 사용');
        _types = _getDefaultData('types');
      }
      
      notifyListeners();
      print('[ClosetProvider] loadCodeTables 완료');
    } catch (e, stackTrace) {
      print('[ClosetProvider] 코드 테이블 로드 실패: $e');
      print('[ClosetProvider] Stack trace: $stackTrace');
      // 에러 발생 시에도 기본 데이터 사용
      _loadFallbackData();
      notifyListeners();
    }
  }
  
  void _loadFallbackData() {
    print('[ClosetProvider] Loading fallback data...');
    _categories = _getDefaultData('categories');
    _colors = _getDefaultData('colors');
    _materials = _getDefaultData('materials');
    _seasons = _getDefaultData('seasons');
    _styles = _getDefaultData('styles');
    _types = _getDefaultData('types');
  }

  /// 모든 코드 테이블의 기본값 (DB의 실제 데이터와 동일)
  /// 동적 로딩 실패시 이 데이터 사용
  List<Map<String, dynamic>> _getDefaultData(String dataType) {
    switch (dataType) {
      case 'categories':
        return [
          {'category_id': 4, 'category_name': '상의'},
          {'category_id': 5, 'category_name': '하의'},
          {'category_id': 6, 'category_name': '신발'},
          {'category_id': 7, 'category_name': '아우터'},
        ];
      case 'colors':
        return [
          {'color_id': 1, 'color_name': '화이트'},
          {'color_id': 2, 'color_name': '블랙'},
          {'color_id': 3, 'color_name': '블루'},
          {'color_id': 4, 'color_name': '네이비'},
          {'color_id': 5, 'color_name': '핑크'},
          {'color_id': 6, 'color_name': '레드'},
          {'color_id': 7, 'color_name': '퍼플'},
          {'color_id': 8, 'color_name': '베이지'},
        ];
      case 'materials':
        return [
          {'material_id': 1, 'material_name': '면'},
          {'material_id': 2, 'material_name': '니트'},
          {'material_id': 3, 'material_name': '데님'},
          {'material_id': 4, 'material_name': '폴리'},
          {'material_id': 5, 'material_name': '린넨'},
          {'material_id': 6, 'material_name': '패딩'},
          {'material_id': 7, 'material_name': '스웨이드'},
          {'material_id': 8, 'material_name': '레더'},
        ];
      case 'seasons':
        return [
          {'season_id': '019b12e6-17b4-72b3-a11b-c01e79f49561', 'season_name': '여름'},
          {'season_id': '019b12f8-e445-7d91-ab93-c7bfbbb20ae7', 'season_name': '봄'},
          {'season_id': '019b12f8-e445-72cf-a22b-32aa8a4ec4e1', 'season_name': '가을'},
          {'season_id': '019b12f8-e445-7e63-b3ab-510ebe0e49b5', 'season_name': '겨울'},
          {'season_id': '019b12f8-e445-7d18-b36c-fa95a1d2ab48', 'season_name': '사계절'},
        ];
      case 'styles':
        return [
          {'style_id': '019b12e5-5d25-747c-987a-623b4f0b7b34', 'style_name': '캐쥬얼'},
          {'style_id': '019b12f9-b0be-796e-a3b0-10384f5bbbb1', 'style_name': '포멀'},
          {'style_id': '019b12f9-b0be-762f-b649-b9262eaad902', 'style_name': '데일리'},
          {'style_id': '019b12f9-b0be-74b1-ac7c-99e345d0aae7', 'style_name': '스트릿'},
          {'style_id': '019b12f9-b0be-7fe8-84e9-b4434ebab581', 'style_name': '러블리'},
          {'style_id': '019b12f9-b0be-74b9-b7b2-8a1443a4fb0c', 'style_name': '미니멀'},
        ];
      case 'types':
        return [
          {'type_id': '019b12e6-8b94-7674-9969-c5e5d6b5ff4c', 'type_name': '셔츠'},
          {'type_id': '019b12fc-3066-74b8-8f79-982f1c5fdcb0', 'type_name': '티셔츠'},
          {'type_id': '019b12fc-3067-783d-be58-a331c3d99062', 'type_name': '맨투맨'},
          {'type_id': '019b12fc-3067-766b-a80c-b5544142ce43', 'type_name': '후드'},
          {'type_id': '019b12fc-3067-7943-8a7a-26f380619cf4', 'type_name': '바지'},
          {'type_id': '019b12fc-3067-780f-b9f7-404fb1ee8777', 'type_name': '치마'},
          {'type_id': '019b12fc-3067-7e07-9519-f0bfadbb309f', 'type_name': '반바지'},
          {'type_id': '019b12fc-3067-704f-aace-60bc275b6f72', 'type_name': '패딩'},
          {'type_id': '019b12fc-3067-75ab-8f9d-a4d79cca44b1', 'type_name': '자켓'},
          {'type_id': '019b12fc-3067-7ebe-9889-bd9a74d6859d', 'type_name': '원피스'},
          {'type_id': '019b12fc-3067-7e17-9d90-0bb5fc810e19', 'type_name': '스니커즈'},
          {'type_id': '019b12fc-3067-7fec-9339-ce75dd423964', 'type_name': '구두'},
          {'type_id': '019b12fc-3067-7ffa-9f64-4e2bc6384266', 'type_name': '부츠'},
        ];
      default:
        return [];
    }
  }
  
  /// 백엔드 API에서 옷 목록 로드 (토큰 필수)
  Future<void> loadClothes(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('[ClosetProvider] 옷 목록 로드 시작');
      final response = await ClothesService.getClothesList(token: token);
      _backendClothes = response.clothes;
      print('[ClosetProvider] 옷 ${_backendClothes.length}개 로드 완료');
      
      // 위시리스트는 로컬에서 로드 (임시)
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      print('[ClosetProvider] 옷 목록 로드 실패: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 위시리스트 로드 (로컬 DB 사용 - 임시)
  Future<void> loadWishlist() async {
    try {
      _wishlistClothes = await Storage.getWishlistClothes();
      notifyListeners();
    } catch (e) {
      print('위시리스트 로드 실패: $e');
    }
  }

  /// 카테고리별 옷 목록 조회
  List<Map<String, dynamic>> getClothesByCategory(String categoryName) {
    // 백엔드 데이터를 Map으로 변환
    List<Map<String, dynamic>> sourceClothes = _backendClothes.map((item) => item.toMap()).toList();
    
    if (categoryName == '전체') return sourceClothes;

    return sourceClothes.where((cloth) {
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
