/// ============================================
/// Notification Provider
/// 알림 상태 관리
/// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../features/notification/models/notification_model.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  Timer? _refreshTimer;
  bool _isLoading = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;

  /// 초기화 및 알림 로드
  Future<void> initialize() async {
    await loadNotifications();
    
    // 30초마다 알림 자동 갱신
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadNotifications();
    });
  }

  /// 백엔드에서 알림 목록 로드
  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await NotificationService.getNotifications();
      
      _notifications = data.map((item) {
        return NotificationModel(
          id: item['id']?.toString() ?? '',
          type: _parseNotificationType(item['type']?.toString() ?? ''),
          title: item['title']?.toString() ?? '',
          message: item['message']?.toString() ?? item['content']?.toString() ?? '',
          createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
          isRead: item['is_read'] == true,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error loading notifications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 알림 타입 파싱
  NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      print('[NotificationProvider] Error marking as read: $e');
    }
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error marking all as read: $e');
    }
  }

  /// 알림 삭제
  Future<void> removeNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error removing notification: $e');
    }
  }

  /// 모든 알림 삭제
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// 수동 새로고침
  Future<void> refresh() async {
    await loadNotifications();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
