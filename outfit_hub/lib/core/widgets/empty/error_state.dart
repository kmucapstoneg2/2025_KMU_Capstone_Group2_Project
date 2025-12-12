import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 에러 상태 위젯
/// ============================================

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 60,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CupertinoButton.filled(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
