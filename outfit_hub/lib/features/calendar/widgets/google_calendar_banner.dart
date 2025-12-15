import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 구글 캘린더 연동 배너 위젯 (축소 버전)
/// ============================================

class GoogleCalendarBanner extends StatelessWidget {
  final bool isLinked;
  final String? linkedEmail;
  final bool isSyncing;
  final VoidCallback onLinkPressed;
  final VoidCallback onUnlinkPressed;
  final VoidCallback onSyncPressed;

  const GoogleCalendarBanner({
    super.key,
    required this.isLinked,
    this.linkedEmail,
    this.isSyncing = false,
    required this.onLinkPressed,
    required this.onUnlinkPressed,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isLinked 
            ? AppColors.primaryLight
            : AppColors.cardBackground,
        borderRadius: AppBorderRadius.small,
        border: Border.all(
          color: isLinked 
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.calendar,
                size: 14,
                color: CupertinoColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLinked ? '구글 캘린더 연동됨' : '구글 캘린더 미연동',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isLinked && linkedEmail != null)
                  Text(
                    linkedEmail!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isLinked)
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              minSize: 0,
              onPressed: isSyncing ? null : onSyncPressed,
              child: isSyncing
                  ? const CupertinoActivityIndicator(radius: 6)
                  : const Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 16,
                      color: AppColors.primary,
                    ),
            )
          else
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              minSize: 0,
              onPressed: onLinkPressed,
              child: const Icon(
                CupertinoIcons.link,
                size: 16,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
