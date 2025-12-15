/// ============================================
/// 쪽지 목록 페이지
/// ============================================

import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/services/message_service.dart';
import 'message_thread_page.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => isLoading = true);
    
    try {
      final data = await MessageService.getReceivedMessages();
      setState(() {
        messages = data;
        isLoading = false;
      });
    } catch (e) {
      print('[MessageListPage] Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('쪽지함'),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.envelope,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '받은 쪽지가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUnread = message['is_read'] != true;
                      
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          color: isUnread
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.background,
                        ),
                        child: CupertinoListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => MessageThreadPage(
                                  userId: message['sender_id']?.toString() ?? '',
                                  userName: message['sender_name']?.toString() ?? '사용자',
                                ),
                              ),
                            ).then((_) => _loadMessages());
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (message['sender_name']?.toString() ?? '?')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message['sender_name']?.toString() ?? '알 수 없음',
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            message['content']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: Text(
                            _formatDate(message['created_at']?.toString()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return DateHelper.formatShort(date);
    }
  }
}
