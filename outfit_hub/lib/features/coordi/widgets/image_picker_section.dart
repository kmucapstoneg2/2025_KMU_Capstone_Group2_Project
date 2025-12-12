import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';

/// ============================================
/// 이미지 선택 섹션
/// ============================================

class ImagePickerSection extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onPick;
  final bool isProcessing;

  const ImagePickerSection({
    super.key,
    this.selectedImage,
    required this.onPick,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI 생성 이미지 (선택)',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: isProcessing
                ? const Center(
                    child: CupertinoActivityIndicator(),
                  )
                : selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.photo_on_rectangle,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'AI 생성 이미지 추가',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
