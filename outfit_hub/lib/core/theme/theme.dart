import 'package:flutter/cupertino.dart';
import 'colors.dart';
import 'spacing.dart';
import 'text_styles.dart';
import 'shadows.dart';

export 'colors.dart';
export 'spacing.dart';
export 'text_styles.dart';
export 'shadows.dart';

/// ============================================
/// 앱 테마 데이터
/// ============================================

class AppTheme {
  static CupertinoThemeData get theme {
    return const CupertinoThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.background,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Border Radius
class AppBorderRadius {
  static BorderRadius get small => BorderRadius.circular(8);
  static BorderRadius get medium => BorderRadius.circular(12);
  static BorderRadius get large => BorderRadius.circular(16);
  static BorderRadius get circle => BorderRadius.circular(999);
}
