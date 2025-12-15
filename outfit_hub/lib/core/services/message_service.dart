/// ============================================
/// 쪽지/메시지 서비스
/// ============================================

import 'api_service.dart';

class MessageService {
  /// 받은 쪽지 목록 조회
  static Future<List<Map<String, dynamic>>> getReceivedMessages() async {
    try {
      final response = await ApiService.get('/messages/inbox');
      
      final messages = (response['data'] as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];

      return messages;
    } catch (e) {
      print('[MessageService] Error getting received messages: $e');
      rethrow;
    }
  }

  /// 보낸 쪽지 목록 조회
  static Future<List<Map<String, dynamic>>> getSentMessages() async {
    try {
      final response = await ApiService.get('/messages/sent');
      
      final messages = (response['data'] as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];

      return messages;
    } catch (e) {
      print('[MessageService] Error getting sent messages: $e');
      rethrow;
    }
  }

  /// 특정 사용자와의 쪽지 스레드 조회
  static Future<List<Map<String, dynamic>>> getMessageThread(String userId) async {
    try {
      final response = await ApiService.get('/messages/thread/$userId');
      
      final messages = (response['data'] as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];

      return messages;
    } catch (e) {
      print('[MessageService] Error getting message thread: $e');
      rethrow;
    }
  }

  /// 쪽지 보내기
  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await ApiService.post(
        '/messages',
        {
          'receiver_id': receiverId,
          'content': content,
        },
      );

      return response['data'] ?? response;
    } catch (e) {
      print('[MessageService] Error sending message: $e');
      rethrow;
    }
  }

  /// 쪽지 읽음 처리
  static Future<void> markAsRead(String messageId) async {
    try {
      await ApiService.patch('/messages/$messageId/read', {});
    } catch (e) {
      print('[MessageService] Error marking message as read: $e');
      rethrow;
    }
  }

  /// 쪽지 삭제
  static Future<void> deleteMessage(String messageId) async {
    try {
      await ApiService.delete('/messages/$messageId');
    } catch (e) {
      print('[MessageService] Error deleting message: $e');
      rethrow;
    }
  }

  /// 읽지 않은 쪽지 개수 조회
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get('/messages/unread/count');
      return response['data']?['count'] ?? 0;
    } catch (e) {
      print('[MessageService] Error getting unread count: $e');
      return 0;
    }
  }
}
