import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_helper.dart';

/// ============================================
/// 게시물 카드
/// ============================================

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    this.isDisliked = false,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['ai_gen_image_url'] as String?;
    final likeCount = post['like_count'] as int? ?? 0;
    final createdAt = post['created_at'] as String?;
    final jsonbData = post['jsonb_data'] as Map<String, dynamic>?;
    final description = jsonbData?['description'] as String?;
    final style = jsonbData?['style'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.greyLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '사용자',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            DateHelper.formatPastDate(
                              DateTime.parse(createdAt),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (style != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        style,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 이미지
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.greyLight,
              child: const Icon(
                CupertinoIcons.photo,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),

            // 액션 버튼
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onLike,
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isLiked
                              ? CupertinoColors.systemRed
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$likeCount',
                          style: TextStyle(
                            color: isLiked
                                ? CupertinoColors.systemRed
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onDislike,
                    child: Icon(
                      isDisliked
                          ? CupertinoIcons.hand_thumbsdown_fill
                          : CupertinoIcons.hand_thumbsdown,
                      color: isDisliked
                          ? CupertinoColors.systemBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onComment,
                    child: const Icon(
                      CupertinoIcons.chat_bubble,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 설명
            if (description != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
