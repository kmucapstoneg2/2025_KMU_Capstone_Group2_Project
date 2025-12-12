import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';

/// ============================================
/// 선택된 옷 미리보기
/// ============================================

class SelectedClothesPreview extends StatelessWidget {
  final List<Map<String, dynamic>> selectedClothes;
  final Function(String) onRemove;

  const SelectedClothesPreview({
    super.key,
    required this.selectedClothes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedClothes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            '선택된 옷이 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedClothes.length,
        itemBuilder: (context, index) {
          final cloth = selectedClothes[index];
          final clothId = cloth['cloth_id'] as String;
          final name = cloth['name'] as String;
          final imageUrl = cloth['image_url'] as String?;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.file(
                                  File(imageUrl),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      CupertinoIcons.photo,
                                      color: AppColors.textSecondary,
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  CupertinoIcons.photo,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                    // 이름
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 삭제 버튼
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(clothId),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 12,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
