/// ============================================
/// Notification List View
/// 알림 목록 화면 - Cupertino 스타일
/// ============================================

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('알림'),
        trailing: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (!provider.hasUnread) return const SizedBox.shrink();
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => provider.markAllAsRead(),
              child: const Icon(CupertinoIcons.checkmark_seal, size: 24),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildConnectionStatus(provider),
                Expanded(child: _buildNotificationList(context, provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(NotificationProvider provider) {
    // REST API 사용으로 연결 상태 표시 제거
    return const SizedBox.shrink();
  }

  Widget _buildNotificationList(BuildContext context, NotificationProvider provider) {
    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bell_slash,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              '알림이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () => provider.markAsRead(notification.id),
          onDismiss: () => provider.removeNotification(notification.id),
        );
      },
    );
  }
}

/// 알림 타일 위젯 - Cupertino 스타일
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: CupertinoColors.systemRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? CupertinoColors.systemBackground 
                : CupertinoColors.systemBlue.withOpacity(0.05),
            border: const Border(
              bottom: BorderSide(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? CupertinoColors.systemGrey5
                      : CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getIconData(notification.type),
                  color: notification.isRead
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ),
              // 읽지 않음 표시
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return CupertinoIcons.heart_fill;
      case NotificationType.comment:
        return CupertinoIcons.chat_bubble_fill;
      case NotificationType.system:
        return CupertinoIcons.bell_fill;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
