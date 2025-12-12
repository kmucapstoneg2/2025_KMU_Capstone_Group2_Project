import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 옷장 아이템 카드
/// ============================================

class ClosetItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isWishlist;
  final VoidCallback? onTap;

  const ClosetItemCard({
    super.key,
    required this.item,
    this.isWishlist = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['image_url'] as String?;
    final name = item['name'] as String? ?? '이름 없음';
    final categoryName = item['category_name'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWishlist ? AppColors.wishlist : AppColors.border,
            width: isWishlist ? 2 : 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 130,
                width: double.infinity,
                color: AppColors.greyLight,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.file(
                        File(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.textSecondary,
                          );
                        },
                      )
                    : const Icon(
                        CupertinoIcons.photo,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),

            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // 카테고리
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // 위시리스트 뱃지
                  if (isWishlist) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.wishlist.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '위시',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.wishlistDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
