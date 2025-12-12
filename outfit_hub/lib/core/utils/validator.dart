import '../constants/app_constants.dart';

/// ============================================
/// 입력 검증 헬퍼
/// ============================================

class Validator {
  /// 옷 이름 검증
  static String? clothName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '옷 이름을 입력해주세요';
    }
    if (value.length > AppConstants.maxClothNameLength) {
      return '${AppConstants.maxClothNameLength}자 이내로 입력해주세요';
    }
    return null;
  }

  /// 가격 검증
  static String? price(String? value) {
    if (value == null || value.isEmpty) return null;

    final price = double.tryParse(value.replaceAll(',', ''));
    if (price == null) {
      return '올바른 가격을 입력해주세요';
    }
    if (price < AppConstants.minPrice) {
      return '${AppConstants.minPrice.toInt()}원 이상 입력해주세요';
    }
    if (price > AppConstants.maxPrice) {
      return '${(AppConstants.maxPrice / 10000).toInt()}만원 이하로 입력해주세요';
    }
    return null;
  }

  /// URL 검증
  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;

    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b',
    );

    if (!urlPattern.hasMatch(value)) {
      return '올바른 URL을 입력해주세요';
    }
    return null;
  }

  /// 일정 제목 검증
  static String? scheduleTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '일정 제목을 입력해주세요';
    }
    if (value.length > AppConstants.maxScheduleTitleLength) {
      return '${AppConstants.maxScheduleTitleLength}자 이내로 입력해주세요';
    }
    return null;
  }

  /// 댓글 내용 검증
  static String? comment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '댓글을 입력해주세요';
    }
    if (value.length > AppConstants.maxCommentLength) {
      return '${AppConstants.maxCommentLength}자 이내로 입력해주세요';
    }
    return null;
  }

  /// 이메일 검증
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// 사용자 이름 검증
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return '${AppConstants.minUsernameLength}자 이상 입력해주세요';
    }
    if (value.length > AppConstants.maxUsernameLength) {
      return '${AppConstants.maxUsernameLength}자 이내로 입력해주세요';
    }
    return null;
  }

  /// 빈 값 검증
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '값'}을 입력해주세요';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return '${fieldName ?? '값'}은 최소 $min자 이상이어야 합니다';
    }
    return null;
  }

  /// 최대 길이 검증
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return '${fieldName ?? '값'}은 최대 $max자 이하여야 합니다';
    }
    return null;
  }

  /// 숫자 범위 검증
  static String? numberRange(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) {
      return '올바른 숫자를 입력해주세요';
    }

    if (number < min || number > max) {
      return '${fieldName ?? '값'}은 $min ~ $max 사이여야 합니다';
    }
    return null;
  }
}
