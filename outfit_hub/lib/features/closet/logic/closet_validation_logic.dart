import '../../../core/utils/validator.dart';

/// ============================================
/// 옷장 검증 로직
/// ============================================

class ClosetValidationLogic {
  /// 옷 추가 검증
  static String? validateAddCloth({
    required String name,
    String? categoryId,
    String? colorId,
    String? materialId,
    String? price, // 사용하지 않지만 호환성 유지
  }) {
    // 이름 검증
    final nameError = Validator.clothName(name);
    if (nameError != null) return nameError;

    // 카테고리 검증
    if (categoryId == null || categoryId.isEmpty) {
      return '카테고리를 선택해주세요';
    }

    // 색상 검증
    if (colorId == null || colorId.isEmpty) {
      return '색상을 선택해주세요';
    }

    // 재질 검증
    if (materialId == null || materialId.isEmpty) {
      return '재질을 선택해주세요';
    }

    return null;
  }

  /// 옷 수정 검증
  static String? validateUpdateCloth({
    required String name,
    String? price, // 사용하지 않지만 호환성 유지
  }) {
    // 이름 검증
    final nameError = Validator.clothName(name);
    if (nameError != null) return nameError;

    return null;
  }
}
