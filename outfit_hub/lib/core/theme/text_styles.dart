import 'package:flutter/cupertino.dart';
import 'colors.dart';

/// ============================================
/// 앱 텍스트 스타일 정의
/// ============================================

class AppTextStyles {
  // 제목
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // 본문
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // 캡션
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // 특수
  static const TextStyle itemName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle tag = TextStyle(
    fontSize: 12,
    color: AppColors.primaryDark,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
