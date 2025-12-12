import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 일정 리스트
/// ============================================

class ScheduleList extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final Function(int) onDelete;

  const ScheduleList({
    super.key,
    required this.schedules,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text(
            '일정이 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final title = schedule['title'] as String;
        final time = schedule['time'] as String?;
        final location = schedule['location'] as String?;
        final tags = schedule['tags'] as List?;

        return Dismissible(
          key: Key(schedule['schedule_id']),
          direction: DismissDirection.endToStart,
          background: Container(
            color: CupertinoColors.systemRed,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: const Icon(
              CupertinoIcons.trash,
              color: CupertinoColors.white,
            ),
          ),
          onDismissed: (_) => onDelete(index),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (time != null || location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (time != null) ...[
                              const Icon(
                                CupertinoIcons.time,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (time != null && location != null)
                              const SizedBox(width: 8),
                            if (location != null) ...[
                              const Icon(
                                CupertinoIcons.location,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (tags != null && tags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
