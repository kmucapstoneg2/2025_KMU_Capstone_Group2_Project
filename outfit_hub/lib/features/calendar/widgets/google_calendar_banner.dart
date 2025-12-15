import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 구글 캘린더 연동 배너 위젯
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
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isLinked 
            ? AppColors.primaryLight  // 앱 테마 연두색 배경
            : AppColors.cardBackground,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(
          color: isLinked 
              ? AppColors.primary  // 앱 테마 초록색 테두리
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 구글 아이콘 (앱 테마 색상)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.calendar,
                    size: 18,
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
                      isLinked ? '구글 캘린더 연동됨' : '구글 캘린더 연동',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isLinked && linkedEmail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        linkedEmail!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLinked) ...[
                // 동기화 버튼
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  minSize: 0,
                  onPressed: isSyncing ? null : onSyncPressed,
                  child: isSyncing
                      ? const CupertinoActivityIndicator()
                      : const Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          size: 20,
                          color: AppColors.primary,
                        ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!isLinked) ...[
            const Text(
              '구글 캘린더를 연동하면 일정을 자동으로 동기화할 수 있습니다.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                onPressed: onLinkPressed,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.calendar_badge_plus,
                      size: 18,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '구글 캘린더 연동하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '일정이 자동으로 동기화됩니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: onUnlinkPressed,
                  child: const Text(
                    '연동 해제',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
