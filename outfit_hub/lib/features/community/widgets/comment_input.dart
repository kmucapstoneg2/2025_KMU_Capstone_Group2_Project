import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 댓글 입력
/// ============================================

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isLoading;

  const CommentInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                placeholder: '댓글을 입력하세요',
                maxLines: null,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            CupertinoButton(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primary,
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
