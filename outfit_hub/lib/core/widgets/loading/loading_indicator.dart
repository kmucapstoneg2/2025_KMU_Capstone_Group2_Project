import 'package:flutter/cupertino.dart';

/// ============================================
/// 로딩 인디케이터
/// ============================================

class AppLoadingIndicator extends StatelessWidget {
  final double radius;

  const AppLoadingIndicator({
    super.key,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(radius: radius),
    );
  }
}

class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoActivityIndicator(radius: 10);
  }
}
