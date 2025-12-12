import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 일정 요약 카드
/// ============================================

class ScheduleSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final VoidCallback? onTap;

  const ScheduleSummaryCard({
    super.key,
    required this.schedules,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '오늘의 일정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${schedules.length}개',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (schedules.isEmpty)
              const Text(
                '오늘 일정이 없습니다',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              ...schedules.take(3).map((schedule) {
                final title = schedule['title'] as String;
                final time = schedule['time'] as String?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (time != null) ...[
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            if (schedules.length > 3) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '외 ${schedules.length - 3}개',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
