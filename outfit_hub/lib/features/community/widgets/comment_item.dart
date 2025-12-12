import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_helper.dart';

/// ============================================
/// 댓글 아이템
/// ============================================

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final content = comment['content'] as String;
    final createdAt = comment['created_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '사용자',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (createdAt != null)
                      Text(
                        DateHelper.formatPastDate(DateTime.parse(createdAt)),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (onDelete != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.trash,
                size: 18,
                color: CupertinoColors.systemRed,
              ),
            ),
        ],
      ),
    );
  }
}
