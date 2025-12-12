/// ============================================
/// Notification Provider
/// 알림 상태 관리
/// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../features/notification/models/notification_model.dart';
import '../features/notification/services/websocket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  
  List<NotificationModel> _notifications = [];
  StreamSubscription<NotificationModel>? _notificationSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;
  
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get hasUnread => unreadCount > 0;
  WebSocketConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;

  /// 초기화 및 WebSocket 연결
  Future<void> initialize({String? userId}) async {
    // 스트림 구독
    _notificationSubscription = _webSocketService.notificationStream.listen(
      _onNotificationReceived,
    );
    
    _connectionSubscription = _webSocketService.connectionStateStream.listen(
      _onConnectionStateChanged,
    );
    
    // WebSocket 연결
    await _webSocketService.connect(userId: userId);
  }

  /// 서버 URL 설정
  void setServerUrl(String url) {
    _webSocketService.setServerUrl(url);
  }

  /// 새 알림 수신 처리
  void _onNotificationReceived(NotificationModel notification) {
    _notifications.insert(0, notification); // 최신 알림을 맨 앞에 추가
    notifyListeners();
  }

  /// 연결 상태 변경 처리
  void _onConnectionStateChanged(WebSocketConnectionState state) {
    _connectionState = state;
    notifyListeners();
  }

  /// 알림 읽음 처리
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _webSocketService.markAsRead(notificationId);
      notifyListeners();
    }
  }

  /// 모든 알림 읽음 처리
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _webSocketService.markAllAsRead();
    notifyListeners();
  }

  /// 알림 삭제
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// 모든 알림 삭제
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// 수동 재연결
  Future<void> reconnect({String? userId}) async {
    _webSocketService.disconnect();
    await _webSocketService.connect(userId: userId);
  }

  /// 테스트용 더미 알림 추가
  void addDummyNotification() {
    final types = NotificationType.values;
    final randomType = types[DateTime.now().millisecond % types.length];
    
    final dummyMessages = {
      NotificationType.like: ('좋아요 알림', '누군가 회원님의 코디를 좋아합니다'),
      NotificationType.comment: ('댓글 알림', '새 댓글이 달렸습니다'),
      NotificationType.system: ('시스템 알림', '앱이 업데이트되었습니다'),
    };
    
    final (title, message) = dummyMessages[randomType]!;
    
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: randomType,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    
    _notifications.insert(0, notification);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}
