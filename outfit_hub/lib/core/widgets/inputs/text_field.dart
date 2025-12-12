import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 기본 입력 필드
/// ============================================

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
      prefix: prefix,
      suffix: suffix,
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
