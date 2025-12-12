/// ============================================
/// Cupertino Notification Widget
/// Cupertino 스타일 알림 아이콘 및 배지 위젯
/// ============================================

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/notification_provider.dart';
import '../services/websocket_service.dart';
import '../views/notification_list_view.dart';

/// 알림 아이콘 버튼 (배지 포함) - Cupertino 스타일
class CupertinoNotificationButton extends StatelessWidget {
  const CupertinoNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => const NotificationListView(),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.bell,
                  size: 24,
                ),
              ),
              if (provider.hasUnread)
                Positioned(
                  right: 4,
                  top: 4,
                  child: _NotificationBadge(count: provider.unreadCount),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 알림 배지 위젯
class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 테스트용 알림 추가 버튼
class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        context.read<NotificationProvider>().addDummyNotification();
        _showToast(context, '테스트 알림이 추가되었습니다');
      },
      child: const Icon(
        CupertinoIcons.add_circled,
        size: 24,
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 연결 상태 표시 위젯 - Cupertino 스타일
class CupertinoConnectionIndicator extends StatelessWidget {
  const CupertinoConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        Color color;

        switch (provider.connectionState) {
          case WebSocketConnectionState.connected:
            color = CupertinoColors.systemGreen;
            break;
          case WebSocketConnectionState.connecting:
          case WebSocketConnectionState.reconnecting:
            color = CupertinoColors.systemOrange;
            break;
          case WebSocketConnectionState.disconnected:
            color = CupertinoColors.systemRed;
            break;
        }

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
