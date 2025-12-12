import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 텍스트 영역
/// ============================================

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final int maxLines;
  final int? maxLength;

  const AppTextArea({
    super.key,
    required this.controller,
    required this.placeholder,
    this.maxLines = 5,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      maxLines: maxLines,
      maxLength: maxLength,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
