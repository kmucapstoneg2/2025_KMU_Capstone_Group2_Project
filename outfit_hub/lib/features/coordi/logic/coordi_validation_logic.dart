/// ============================================
/// 코디 검증 로직
/// ============================================

class CoordiValidationLogic {
  /// 코디 저장 검증
  static String? validateSaveOutfit({
    required List<String> clothIds,
    String? weatherId,
  }) {
    // 옷 선택 검증
    if (clothIds.isEmpty) {
      return '최소 1개 이상의 옷을 선택해주세요';
    }

    // 날씨 정보 검증
    if (weatherId == null || weatherId.isEmpty) {
      return '날씨 정보가 없습니다';
    }

    return null;
  }

  /// 최소 옷 개수 검증
  static bool hasMinimumClothes(List<String> clothIds, {int minimum = 1}) {
    return clothIds.length >= minimum;
  }

  /// 최대 옷 개수 검증
  static bool hasMaximumClothes(List<String> clothIds, {int maximum = 10}) {
    return clothIds.length <= maximum;
  }
}
