import '../../core/services/api_service.dart';

/// Message 레파지토리 - 메시지 관련 API

class Message {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? content;
  final DateTime? createdAt;
  final bool? isRead;

  Message({
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.createdAt,
    this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? json['messageId']?.toString(),
      senderId: json['senderId']?.toString(),
      receiverId: json['receiverId']?.toString(),
      content: json['content'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      isRead: json['isRead'] ?? json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'isRead': isRead,
    };
  }
}

class MessageRepository {
  /// 메시지 전송
  static Future<Message?> sendMessage({
    required String receiverId,
    required String content,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        '/messages',
        {
          'receiverId': receiverId,
          'content': content,
        },
        token: token,
      );
      return Message.fromJson(response);
    } catch (e) {
      print('메시지 전송 실패: $e');
      return null;
    }
  }

  /// 받은 메시지함 조회
  static Future<List<Message>> getInbox({String? token}) async {
    try {
      final response = await ApiService.get('/messages/inbox', token: token);
      if (response['data'] is List) {
        return (response['data'] as List).map((e) => Message.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('받은 메시지 조회 실패: $e');
      return [];
    }
  }

  /// 보낸 메시지함 조회
  static Future<List<Message>> getSentMessages({String? token}) async {
    try {
      final response = await ApiService.get('/messages/sent', token: token);
      if (response['data'] is List) {
        return (response['data'] as List).map((e) => Message.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('보낸 메시지 조회 실패: $e');
      return [];
    }
  }
}
