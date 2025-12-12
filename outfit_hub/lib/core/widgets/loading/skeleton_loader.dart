import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/theme.dart';

/// ============================================
/// Skeleton 로더
/// ============================================

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.greyLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: borderRadius ?? AppBorderRadius.medium,
        ),
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 210,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        return const SkeletonLoader(
          width: double.infinity,
          height: 210,
        );
      },
    );
  }
}
