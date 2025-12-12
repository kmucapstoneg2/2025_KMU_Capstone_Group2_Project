import 'package:flutter/cupertino.dart';

/// ============================================
/// 앱 그림자 정의
/// ============================================

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
}
