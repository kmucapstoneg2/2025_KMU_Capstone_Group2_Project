import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';

class OutfitRecommendCard extends StatelessWidget {
  final Map<String, dynamic> cloth;
  final VoidCallback? onTap;

  const OutfitRecommendCard({
    super.key,
    required this.cloth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = cloth['name'] as String;
    final imageUrl = cloth['image_url'] as String?;
    final categoryName = cloth['category_name'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              CupertinoIcons.photo,
                              color: AppColors.textSecondary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        CupertinoIcons.photo,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (categoryName != null)
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
