import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 검색 입력 필드
/// ============================================

class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    required this.controller,
    this.placeholder = '검색',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      onSuffixTap: onClear,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}
