import 'package:flutter/cupertino.dart';

/// ============================================
/// 앱 색상 정의
/// ============================================

class AppColors {
  // 메인 테마 (연두색 계열)
  static const Color primary = Color(0xFFA1CE5D);
  static const Color primaryDark = Color(0xFF8DB84F);
  static const Color primaryLight = Color(0xFFE7F4D4);

  // 위시리스트 전용 초록
  static const Color wishlist = Color(0xFF79B93F);
  static const Color wishlistDark = Color(0xFF5F8F32);

  // 배경색
  static const Color background = CupertinoColors.white;
  static const Color cardBackground = Color(0xFFF9F9F9);

  // 텍스트 색상
  static const Color textPrimary = CupertinoColors.black;
  static const Color textSecondary = CupertinoColors.systemGrey;

  // 테두리 색상
  static const Color border = Color(0xFFE5E5E5);

  // 공통 회색
  static const Color greyLight = Color(0xFFF2F2F2);
  static const Color greyText = Color(0xFF777777);

  // 상태 색상
  static const Color success = Color(0xFF4CAF50);
  static const Color error = CupertinoColors.systemRed;
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}
