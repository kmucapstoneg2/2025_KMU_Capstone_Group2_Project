/// ============================================
/// 앱 상수
/// ============================================

class AppConstants {
  // 기본 사용자 ID
  static const String defaultUserId = 'user_default';

  // 페이지네이션
  static const int pageSize = 20;

  // 이미지
  static const int maxImageSizeInMB = 10;
  static const int imageQuality = 85;
  static const int thumbnailQuality = 70;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int thumbnailSize = 300;

  // 캐시
  static const int cacheDurationInDays = 7;
  static const int oldImageCleanupDays = 30;

  // 입력 제한
  static const int maxClothNameLength = 50;
  static const int maxScheduleTitleLength = 100;
  static const int maxCommentLength = 500;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 2;

  // 가격 제한
  static const double maxPrice = 10000000;
  static const double minPrice = 0;

  // 날짜 형식
  static const String dateKeyFormat = 'yyyy-MM-dd';
  static const String dateDisplayFormat = 'M월 d일';
  static const String dateFullFormat = 'yyyy년 M월 d일';
  static const String timeFormat = 'HH:mm';

  // 기본 지역
  static const String defaultRegion = '서울';
}
