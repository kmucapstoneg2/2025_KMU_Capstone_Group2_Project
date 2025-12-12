import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/validator.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 게시물 상세 페이지
/// ============================================

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  bool isSubmitting = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final outfitId = widget.post['outfit_id'] as String;
      final loadedComments = await CommentLogic.getComments(outfitId);
      final liked = await PostLogic.isLiked(outfitId);

      setState(() {
        comments = loadedComments;
        isLiked = liked;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        await ErrorHandler.showError(context, e, onRetry: _loadData);
      }
    }
  }

  Future<void> _toggleLike() async {
    try {
      final outfitId = widget.post['outfit_id'] as String;
      final newStatus = await PostLogic.toggleLike(outfitId);
      setState(() => isLiked = newStatus);
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _addComment() async {
    final content = commentController.text.trim();
    final error = Validator.comment(content);
    
    if (error != null) {
      await DialogHelper.showAlert(context, title: '알림', content: error);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final outfitId = widget.post['outfit_id'] as String;
      await CommentLogic.addComment(outfitId: outfitId, content: content);
      commentController.clear();
      await _loadData();
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _deleteComment(String interactionId) async {
    final confirmed = await DialogHelper.showDeleteConfirm(
      context,
      title: '댓글을 삭제하시겠습니까?',
    );

    if (!confirmed) return;

    try {
      await CommentLogic.deleteComment(interactionId);
      await _loadData();
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post['ai_gen_image_url'] as String?;
    final likeCount = widget.post['like_count'] as int? ?? 0;
    final jsonbData = widget.post['jsonb_data'] as Map<String, dynamic>?;
    final description = jsonbData?['description'] as String?;
    final style = jsonbData?['style'] as String?;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('게시물'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지
                    Container(
                      height: 400,
                      width: double.infinity,
                      color: AppColors.greyLight,
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // 정보
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 액션 버튼
                          Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _toggleLike,
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: isLiked ? CupertinoColors.systemRed : AppColors.textPrimary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$likeCount',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isLiked ? CupertinoColors.systemRed : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const Icon(CupertinoIcons.chat_bubble, size: 28),
                              const SizedBox(width: 4),
                              Text('${comments.length}', style: const TextStyle(fontSize: 18)),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 스타일 태그
                          if (style != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                style,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const SizedBox(height: AppSpacing.md),

                          // 설명
                          if (description != null)
                            Text(description, style: const TextStyle(fontSize: 16)),

                          const SizedBox(height: AppSpacing.xl),

                          // 댓글 섹션
                          const Text(
                            '댓글',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),

                    // 댓글 리스트
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: AppLoadingIndicator(),
                      )
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Text(
                            '첫 댓글을 남겨보세요!',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ...comments.map((comment) {
                        return CommentItem(
                          comment: comment,
                          onDelete: () => _deleteComment(comment['interaction_id']),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),

            // 댓글 입력
            CommentInput(
              controller: commentController,
              onSubmit: _addComment,
              isLoading: isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
