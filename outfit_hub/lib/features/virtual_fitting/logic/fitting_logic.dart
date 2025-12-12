/// ============================================
/// 가상 피팅 비즈니스 로직
/// ============================================

class FittingLogic {
  /// 가상 피팅 처리 (준비중)
  static Future<String?> processFitting({
    required String userImagePath,
    required String clothImagePath,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return null;
  }
}
