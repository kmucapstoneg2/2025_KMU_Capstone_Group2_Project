/// ============================================
/// 알림 서비스
/// ============================================

import 'api_service.dart';

class NotificationService {
  /// 모든 알림 목록 조회
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await ApiService.get('/notifications');
      
      final notifications = (response['data'] as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];

      return notifications;
    } catch (e) {
      print('[NotificationService] Error getting notifications: $e');
      rethrow;
    }
  }

  /// 알림 읽음 처리
  static Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.patch('/notifications/$notificationId/read', {});
    } catch (e) {
      print('[NotificationService] Error marking notification as read: $e');
      rethrow;
    }
  }

  /// 모든 알림 읽음 처리
  static Future<void> markAllAsRead() async {
    try {
      await ApiService.patch('/notifications/read-all', {});
    } catch (e) {
      print('[NotificationService] Error marking all as read: $e');
      rethrow;
    }
  }

  /// 알림 삭제
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await ApiService.delete('/notifications/$notificationId');
    } catch (e) {
      print('[NotificationService] Error deleting notification: $e');
      rethrow;
    }
  }

  /// 읽지 않은 알림 개수 조회
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get('/notifications/unread/count');
      return response['data']?['count'] ?? 0;
    } catch (e) {
      print('[NotificationService] Error getting unread count: $e');
      return 0;
    }
  }
}
