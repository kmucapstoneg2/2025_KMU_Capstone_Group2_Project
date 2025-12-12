import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 최근 코디 카드
/// ============================================

class RecentOutfitCard extends StatelessWidget {
  final List<Map<String, dynamic>> outfits;
  final VoidCallback? onTap;

  const RecentOutfitCard({
    super.key,
    required this.outfits,
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
                  '오늘 일정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (outfits.isEmpty)
              const Text(
                '오늘 일정이 없습니다',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final outfit = outfits[index];
                    final imageUrl = outfit['ai_gen_image_url'] as String?;

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: const Icon(
                                CupertinoIcons.calendar,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.calendar,
                              color: AppColors.textSecondary,
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
