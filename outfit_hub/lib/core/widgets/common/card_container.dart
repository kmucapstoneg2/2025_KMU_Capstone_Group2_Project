import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 카드 컨테이너
/// ============================================

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
