/// ============================================
/// 쪽지 대화 스레드 페이지
/// ============================================

import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

import '../../../core/services/message_service.dart';

class MessageThreadPage extends StatefulWidget {
  final String userId;
  final String userName;

  const MessageThreadPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends State<MessageThreadPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => isLoading = true);
    
    try {
      final data = await MessageService.getMessageThread(widget.userId);
      setState(() {
        messages = data;
        isLoading = false;
      });
      
      // 스크롤을 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('[MessageThreadPage] Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() => isSending = true);
    
    try {
      await MessageService.sendMessage(
        receiverId: widget.userId,
        content: content,
      );
      
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      print('[MessageThreadPage] Send error: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('오류'),
            content: const Text('쪽지 전송에 실패했습니다'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.userName),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : messages.isEmpty
                      ? const Center(
                          child: Text(
                            '대화를 시작하세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message['is_sender'] == true;
                            
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['content']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isMe
                                            ? AppColors.background
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(message['created_at']?.toString()),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? AppColors.background.withValues(alpha: 0.7)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: '메시지 입력...',
                      maxLines: null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: isSending ? null : _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const CupertinoActivityIndicator(
                              color: AppColors.background,
                            )
                          : const Icon(
                              CupertinoIcons.arrow_up,
                              color: AppColors.background,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
