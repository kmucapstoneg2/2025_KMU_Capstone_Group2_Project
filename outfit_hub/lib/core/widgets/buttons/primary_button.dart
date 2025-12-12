import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 기본 버튼
/// ============================================

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        color: AppColors.primary,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(
                color: CupertinoColors.white,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: CupertinoColors.white),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
