/// ============================================
/// Notification Model
/// 실시간 알림 데이터 모델
/// ============================================

enum NotificationType {
  like,      // 좋아요 알림
  comment,   // 댓글 알림
  system,    // 시스템 알림
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // 추가 데이터 (예: 이동할 화면 정보)

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  /// JSON에서 모델 생성
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: _parseNotificationType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  /// 읽음 상태 변경된 복사본 반환
  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// 알림 타입 문자열 파싱
  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
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

  /// 알림 타입별 아이콘 이름 반환
  String get iconName {
    switch (type) {
      case NotificationType.like:
        return 'favorite';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.system:
        return 'notifications';
    }
  }
}
