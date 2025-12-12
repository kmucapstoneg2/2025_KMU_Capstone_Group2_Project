import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 빈 상태 위젯
/// ============================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CupertinoButton.filled(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
