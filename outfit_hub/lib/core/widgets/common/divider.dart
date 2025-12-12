import 'package:flutter/cupertino.dart';
import '../../theme/theme.dart';

/// ============================================
/// 구분선
/// ============================================

class AppDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const AppDivider({
    super.key,
    this.height = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color ?? AppColors.border,
    );
  }
}
