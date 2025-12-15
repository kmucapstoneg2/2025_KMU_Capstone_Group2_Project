/// ============================================
/// Notification Widget
/// 알림 아이콘 및 배지 위젯
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/notification_provider.dart';
import '../views/notification_list_view.dart';

/// 알림 아이콘 버튼 (배지 포함)
class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationListView(),
                  ),
                );
              },
            ),
            if (provider.hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: NotificationBadge(count: provider.unreadCount),
              ),
          ],
        );
      },
    );
  }
}

/// 알림 배지 위젯
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        displayCount,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 연결 상태 표시 위젯
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // REST API 사용으로 연결 상태 표시 제거
        return Tooltip(
          message: '알림',
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
