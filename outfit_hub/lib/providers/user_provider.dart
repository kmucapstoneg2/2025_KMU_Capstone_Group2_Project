import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';

/// ============================================
/// 사용자 Provider
/// ============================================

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  int _clothCount = 0;
  int _outfitCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get user => _user;
  int get clothCount => _clothCount;
  int get outfitCount => _outfitCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get username => _user?['username'] ?? '사용자';
  String get email => _user?['email'] ?? '';
  String get region => _user?['region'] ?? '서울';
  String? get profileImageUrl => _user?['profile_image_url'];

  /// 초기화
  Future<void> init() async {
    await loadUserData();
  }

  /// 사용자 데이터 로드
  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await Storage.getCurrentUser();
      _clothCount = await Storage.getTotalClothCount();
      _outfitCount = await Storage.getTotalOutfitCount();
    } catch (e) {
      _error = e.toString();
      throw StorageException('사용자 정보를 불러오는데 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 정보 수정
  Future<void> updateUser(Map<String, dynamic> updates) async {
    try {
      await Storage.updateUser(updates);
      await loadUserData();
    } catch (e) {
      throw StorageException('사용자 정보 수정에 실패했습니다');
    }
  }

  /// 통계 새로고침
  Future<void> refreshStats() async {
    try {
      _clothCount = await Storage.getTotalClothCount();
      _outfitCount = await Storage.getTotalOutfitCount();
      notifyListeners();
    } catch (e) {
      print('통계 새로고침 실패: $e');
    }
  }

  /// 프로필 이미지 업데이트
  Future<void> updateProfileImage(String imageUrl) async {
    try {
      await updateUser({'profile_image_url': imageUrl});
    } catch (e) {
      throw StorageException('프로필 이미지 업데이트에 실패했습니다');
    }
  }

  /// 사용자 이름 업데이트
  Future<void> updateUsername(String username) async {
    try {
      await updateUser({'username': username});
    } catch (e) {
      throw StorageException('사용자 이름 업데이트에 실패했습니다');
    }
  }

  /// 지역 업데이트
  Future<void> updateRegion(String region) async {
    try {
      await updateUser({'region': region});
    } catch (e) {
      throw StorageException('지역 업데이트에 실패했습니다');
    }
  }
}
