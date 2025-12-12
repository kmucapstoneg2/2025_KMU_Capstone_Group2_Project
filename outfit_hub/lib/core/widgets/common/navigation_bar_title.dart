import 'package:flutter/cupertino.dart';

/// ============================================
/// 네비게이션 바 타이틀
/// ============================================

class NavigationBarTitle extends StatelessWidget {
  final String title;

  const NavigationBarTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        inherit: false,
      ),
    );
  }
}
