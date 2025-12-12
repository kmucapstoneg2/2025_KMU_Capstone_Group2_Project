import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 텍스트 버튼
/// ============================================

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}
