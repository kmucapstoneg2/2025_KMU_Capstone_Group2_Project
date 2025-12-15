import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';
import '../core/utils/date_helper.dart';
import '../core/services/google_calendar_service.dart';

/// ============================================
/// 캘린더 Provider
/// ============================================

class CalendarProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _schedules = {};
  Map<String, List<Map<String, dynamic>>> _outfits = {};
  bool _isLoading = false;
  String? _error;
  
  // 구글 캘린더 연동 관련
  bool _isGoogleLinked = false;
  String? _googleLinkedEmail;
  bool _isSyncing = false;

  // Getters
  Map<String, List<Map<String, dynamic>>> get schedules => _schedules;
  Map<String, List<Map<String, dynamic>>> get outfits => _outfits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 구글 캘린더 Getters
  bool get isGoogleLinked => _isGoogleLinked;
  String? get googleLinkedEmail => _googleLinkedEmail;
  bool get isSyncing => _isSyncing;

  /// 초기화
  Future<void> init() async {
    await checkGoogleCalendarStatus();
    await loadData();
  }
  
  /// 구글 캘린더 연동 상태 확인
  Future<void> checkGoogleCalendarStatus() async {
    _isGoogleLinked = await GoogleCalendarService.isLinked();
    _googleLinkedEmail = await GoogleCalendarService.getLinkedEmail();
    notifyListeners();
  }

  /// 데이터 로드
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await Storage.getSchedules();
      
      // 코디를 날짜별로 그룹화
      final allOutfits = await Storage.getOutfits();
      _outfits = {};
      
      for (final outfit in allOutfits) {
        final createdAt = outfit['created_at'] as String?;
        if (createdAt != null) {
          final date = DateTime.parse(createdAt);
          final dateKey = DateHelper.toDateKey(date);
          
          if (!_outfits.containsKey(dateKey)) {
            _outfits[dateKey] = [];
          }
          _outfits[dateKey]!.add(outfit);
        }
      }
    } catch (e) {
      _error = e.toString();
      throw StorageException('캘린더 데이터를 불러오는데 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 날짜의 일정 조회
  List<Map<String, dynamic>> getSchedulesByDate(String dateKey) {
    return _schedules[dateKey] ?? [];
  }

  /// 특정 날짜의 코디 조회
  List<Map<String, dynamic>> getOutfitsByDate(String dateKey) {
    return _outfits[dateKey] ?? [];
  }

  /// 일정 추가
  Future<void> addSchedule({
    required String dateKey,
    required String title,
    String? time,
    String? location,
    List<String>? tags,
  }) async {
    try {
      await Storage.addSchedule(
        dateKey: dateKey,
        title: title,
        time: time,
        location: location,
        tags: tags,
      );
      await loadData();
    } catch (e) {
      throw StorageException('일정 추가에 실패했습니다');
    }
  }

  /// 일정 삭제
  Future<void> deleteSchedule(String dateKey, int index) async {
    try {
      await Storage.deleteSchedule(dateKey, index);
      await loadData();
    } catch (e) {
      throw StorageException('일정 삭제에 실패했습니다');
    }
  }

  /// 특정 날짜에 일정이나 코디가 있는지 확인
  bool hasDataOnDate(String dateKey) {
    return (_schedules[dateKey]?.isNotEmpty ?? false) ||
        (_outfits[dateKey]?.isNotEmpty ?? false);
  }

  /// 특정 날짜의 전체 데이터 개수
  int getDataCountOnDate(String dateKey) {
    final scheduleCount = _schedules[dateKey]?.length ?? 0;
    final outfitCount = _outfits[dateKey]?.length ?? 0;
    return scheduleCount + outfitCount;
  }
  
  // ========== 구글 캘린더 연동 관련 ==========
  
  /// 구글 캘린더 연동 완료 처리
  Future<void> linkGoogleCalendar({
    required String accessToken,
    String? refreshToken,
    String? email,
  }) async {
    await GoogleCalendarService.completeGoogleLink(
      accessToken: accessToken,
      refreshToken: refreshToken,
      email: email,
    );
    _isGoogleLinked = true;
    _googleLinkedEmail = email;
    notifyListeners();
  }
  
  /// 구글 캘린더 연동 해제
  Future<void> unlinkGoogleCalendar() async {
    await GoogleCalendarService.unlinkGoogleCalendar();
    _isGoogleLinked = false;
    _googleLinkedEmail = null;
    notifyListeners();
  }
  
  /// 구글 캘린더 동기화 (백엔드에서 일정 가져오기)
  Future<void> syncGoogleCalendar({required String userToken}) async {
    if (!_isGoogleLinked) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      await GoogleCalendarService.fetchSchedules(userToken: userToken);
      await loadData();
    } catch (e) {
      throw StorageException('구글 캘린더 동기화에 실패했습니다: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 구글 캘린더에 일정 추가
  Future<void> addScheduleToGoogle({
    required String userToken,
    required String dateKey,
    required String title,
    String? time,
    String? location,
    String? description,
  }) async {
    if (!_isGoogleLinked) {
      // 연동 안 됐으면 로컬에만 저장
      await addSchedule(
        dateKey: dateKey,
        title: title,
        time: time,
        location: location,
      );
      return;
    }
    
    try {
      // 날짜와 시간을 ISO 8601 형식으로 변환
      final dateParts = dateKey.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      String startTime;
      String endTime;
      
      if (time != null && time.isNotEmpty) {
        final timeParts = time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        
        final startDateTime = DateTime(year, month, day, hour, minute);
        final endDateTime = startDateTime.add(const Duration(hours: 1));
        
        startTime = startDateTime.toIso8601String();
        endTime = endDateTime.toIso8601String();
      } else {
        // 시간이 없으면 종일 일정으로 처리
        final startDateTime = DateTime(year, month, day, 9, 0);
        final endDateTime = DateTime(year, month, day, 10, 0);
        
        startTime = startDateTime.toIso8601String();
        endTime = endDateTime.toIso8601String();
      }
      
      await GoogleCalendarService.addScheduleToGoogle(
        userToken: userToken,
        title: title,
        description: location != null ? '장소: $location' : description,
        startTime: startTime,
        endTime: endTime,
      );
      
      // 로컬에도 저장
      await addSchedule(
        dateKey: dateKey,
        title: title,
        time: time,
        location: location,
      );
    } catch (e) {
      throw StorageException('구글 캘린더에 일정 추가 실패: $e');
    }
  }
}
