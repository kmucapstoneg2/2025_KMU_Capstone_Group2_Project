/// ============================================
/// WebSocket Service
/// 실시간 알림을 위한 WebSocket 연결 관리
/// ============================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/notification_model.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocket? _socket;
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  
  // 재연결 관련 설정
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  
  // 알림 스트림
  final _notificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
  
  // 연결 상태 스트림
  final _connectionStateController = StreamController<WebSocketConnectionState>.broadcast();
  Stream<WebSocketConnectionState> get connectionStateStream => _connectionStateController.stream;
  
  WebSocketConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;

  /// WebSocket 서버 URL (실제 서버 URL로 변경 필요)
  String _serverUrl = 'ws://localhost:8080/ws/notifications';
  
  /// 서버 URL 설정
  void setServerUrl(String url) {
    _serverUrl = url;
  }

  /// WebSocket 연결
  Future<void> connect({String? userId}) async {
    if (_connectionState == WebSocketConnectionState.connecting ||
        _connectionState == WebSocketConnectionState.connected) {
      return;
    }

    _updateConnectionState(WebSocketConnectionState.connecting);
    
    try {
      final url = userId != null ? '$_serverUrl?userId=$userId' : _serverUrl;
      _socket = await WebSocket.connect(url);
      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      
      _socket!.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
      
      print('✅ WebSocket 연결 성공: $url');
    } catch (e) {
      print('❌ WebSocket 연결 실패: $e');
      _updateConnectionState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// 메시지 처리
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      
      // 알림 메시지 처리
      if (data['type'] == 'notification') {
        final notification = NotificationModel.fromJson(data['payload']);
        _notificationController.add(notification);
        print('📬 새 알림 수신: ${notification.title}');
      }
      // ping/pong 처리 (연결 유지용)
      else if (data['type'] == 'ping') {
        _sendPong();
      }
    } catch (e) {
      print('⚠️ 메시지 파싱 오류: $e');
    }
  }

  /// 에러 처리
  void _handleError(dynamic error) {
    print('❌ WebSocket 에러: $error');
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  /// 연결 종료 처리
  void _handleDisconnect() {
    print('🔌 WebSocket 연결 종료');
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  /// 재연결 스케줄링
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ 최대 재연결 시도 횟수 초과');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      print('🔄 재연결 시도 $_reconnectAttempts/$_maxReconnectAttempts');
      _updateConnectionState(WebSocketConnectionState.reconnecting);
      connect();
    });
  }

  /// 연결 상태 업데이트
  void _updateConnectionState(WebSocketConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Pong 응답 전송
  void _sendPong() {
    sendMessage({'type': 'pong'});
  }

  /// 메시지 전송
  void sendMessage(Map<String, dynamic> message) {
    if (_socket != null && _connectionState == WebSocketConnectionState.connected) {
      _socket!.add(jsonEncode(message));
    }
  }

  /// 알림 읽음 처리 요청
  void markAsRead(String notificationId) {
    sendMessage({
      'type': 'mark_read',
      'notificationId': notificationId,
    });
  }

  /// 모든 알림 읽음 처리 요청
  void markAllAsRead() {
    sendMessage({
      'type': 'mark_all_read',
    });
  }

  /// 연결 종료
  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _reconnectAttempts = 0;
    print('🔌 WebSocket 연결 해제');
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStateController.close();
  }
}
