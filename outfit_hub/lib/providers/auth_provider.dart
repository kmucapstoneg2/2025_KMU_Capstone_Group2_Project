import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';
import '../core/services/api_service.dart';
import '../data/storage.dart';
import '../core/utils/jwt_helper.dart';

/// ============================================
/// 인증 Provider
/// SharedPreferences를 사용하여 인증 상태 저장
/// ============================================

class AuthProvider extends ChangeNotifier {
      // 자동 로그인용 이메일/비밀번호(암호화 필요, 1차 평문 저장)
      static const String _keyLoginEmail = 'auth_login_email';
      static const String _keyLoginPassword = 'auth_login_password';
      String? _loginEmail;
      String? _loginPassword;
      /// 자동 로그인 정보 저장
      Future<void> _saveLoginInfo(String email, String password) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyLoginEmail, email);
          await prefs.setString(_keyLoginPassword, password);
          _loginEmail = email;
          _loginPassword = password;
        } catch (e) {
          print('로그인 정보 저장 실패: $e');
        }
      }

      /// 자동 로그인 정보 로드
      Future<void> _loadLoginInfo() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          _loginEmail = prefs.getString(_keyLoginEmail);
          _loginPassword = prefs.getString(_keyLoginPassword);
        } catch (e) {
          print('로그인 정보 로드 실패: $e');
        }
      }

      /// 자동 로그인 정보 삭제
      Future<void> _clearLoginInfo() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_keyLoginEmail);
          await prefs.remove(_keyLoginPassword);
          _loginEmail = null;
          _loginPassword = null;
        } catch (e) {
          print('로그인 정보 삭제 실패: $e');
        }
      }
    /// accessToken 만료 여부 반환
    bool get isTokenExpired {
      if (_accessToken == null) return true;
      return JwtHelper.isExpired(_accessToken!);
    }

    /// accessToken 만료 시 자동 재로그인 시도 (refresh 미구현 시)
    Future<void> checkAndHandleToken() async {
      if (isTokenExpired) {
        // 자동 로그인 정보가 있으면 재로그인 시도
        await _loadLoginInfo();
        if (_loginEmail != null && _loginPassword != null) {
          try {
            await login(email: _loginEmail!, password: _loginPassword!);
            print('만료 토큰 → 자동 재로그인 성공');
          } catch (e) {
            print('만료 토큰 → 자동 재로그인 실패: $e');
            await logout();
          }
        } else {
          await logout();
        }
      }
    }
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyIsGuest = 'auth_is_guest';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyEmail = 'auth_email';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyRegion = 'auth_region';

  bool _isLoggedIn = false;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _error;
  
  String? _userId;
  String? _username;
  String? _email;
  String? _accessToken;
  String? _refreshToken;
  String? _region;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get accessToken => _accessToken;
  String? get region => _region;
  bool get isAuthenticated => _isLoggedIn || _isGuest;

  /// 초기화 - 저장된 인증 상태 복원
  Future<void> init() async {
    await _loadAuthState();
    await checkAndHandleToken();
  }

  /// 저장된 인증 상태 로드
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _isGuest = prefs.getBool(_keyIsGuest) ?? false;
      _userId = prefs.getString(_keyUserId);
      _username = prefs.getString(_keyUsername);
      _email = prefs.getString(_keyEmail);
      _accessToken = prefs.getString(_keyAccessToken);
      _refreshToken = prefs.getString(_keyRefreshToken);
      _region = prefs.getString(_keyRegion);
      await _loadLoginInfo();
      
      notifyListeners();
    } catch (e) {
      print('인증 상태 로드 실패: $e');
    }
  }

  /// 인증 상태 저장
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_keyIsLoggedIn, _isLoggedIn);
      await prefs.setBool(_keyIsGuest, _isGuest);
      
      if (_userId != null) {
        await prefs.setString(_keyUserId, _userId!);
      } else {
        await prefs.remove(_keyUserId);
      }
      
      if (_username != null) {
        await prefs.setString(_keyUsername, _username!);
      } else {
        await prefs.remove(_keyUsername);
      }
      
      if (_email != null) {
        await prefs.setString(_keyEmail, _email!);
      } else {
        await prefs.remove(_keyEmail);
      }
      
      if (_accessToken != null) {
        await prefs.setString(_keyAccessToken, _accessToken!);
      } else {
        await prefs.remove(_keyAccessToken);
      }
      
      if (_refreshToken != null) {
        await prefs.setString(_keyRefreshToken, _refreshToken!);
      } else {
        await prefs.remove(_keyRefreshToken);
      }
      
      if (_region != null) {
        await prefs.setString(_keyRegion, _region!);
      } else {
        await prefs.remove(_keyRegion);
      }
    } catch (e) {
      print('인증 상태 저장 실패: $e');
    }
  }

  /// 인증 상태 초기화
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyIsGuest);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyRegion);
      await _clearLoginInfo();
    } catch (e) {
      print('인증 상태 초기화 실패: $e');
    }
  }

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? region,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signUp(
        email: email,
        password: password,
        username: username,
        region: region,
      );
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      _isLoggedIn = true;
      _isGuest = false;
      _userId = response.userId;
      _username = response.username;
      _email = email;
      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;

      await _saveAuthState();
      await _saveLoginInfo(email, password);
      await checkAndHandleToken();
      
      // UserProvider(로컬 DB)의 username도 업데이트하여 홈 화면과 동기화
      try {
        await Storage.updateUser({'username': response.username});
      } catch (e) {
        print('UserProvider username 업데이트 실패: $e');
      }
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 게스트 로그인
  Future<void> loginAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isLoggedIn = false;
      _isGuest = true;
      _userId = 'guest_user';
      _username = '게스트';
      _email = null;
      _accessToken = null;
      _refreshToken = null;

      await _saveAuthState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = false;
      _isGuest = false;
      _userId = null;
      _username = null;
      _email = null;
      _accessToken = null;
      _refreshToken = null;

      await _clearAuthState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 사용자명 업데이트
  Future<void> updateUsername(String newUsername) async {
    _username = newUsername;
    await _saveAuthState();
    notifyListeners();
  }

  /// region 업데이트 (프로필 수정 시)
  Future<void> updateRegion(String newRegion) async {
    _region = newRegion;
    await _saveAuthState();
    notifyListeners();
  }
}
