import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';
import '../core/utils/date_helper.dart';

/// ============================================
/// 캘린더 Provider
/// ============================================

class CalendarProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _schedules = {};
  Map<String, List<Map<String, dynamic>>> _outfits = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, List<Map<String, dynamic>>> get schedules => _schedules;
  Map<String, List<Map<String, dynamic>>> get outfits => _outfits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 초기화
  Future<void> init() async {
    await loadData();
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
}
