import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 코디 리스트
/// ============================================

class OutfitList extends StatelessWidget {
  final List<Map<String, dynamic>> outfits;
  final VoidCallback? onTap;

  const OutfitList({
    super.key,
    required this.outfits,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (outfits.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text(
            '저장된 코디',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final imageUrl = outfit['ai_gen_image_url'] as String?;

              return GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 100,
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
                            CupertinoIcons.photo,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.photo,
                          color: AppColors.textSecondary,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
