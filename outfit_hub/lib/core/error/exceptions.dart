/// ============================================
/// 커스텀 예외 클래스
/// ============================================

class AppException implements Exception {
  final String message;
  final String code;

  AppException(this.message, this.code);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(
          message ?? '네트워크 연결을 확인해주세요',
          'NETWORK_ERROR',
        );
}

class StorageException extends AppException {
  StorageException([String? message])
      : super(
          message ?? '데이터 저장에 실패했습니다',
          'STORAGE_ERROR',
        );
}

class ValidationException extends AppException {
  ValidationException(String message)
      : super(message, 'VALIDATION_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(
          message ?? '데이터를 찾을 수 없습니다',
          'NOT_FOUND',
        );
}

class ImageProcessingException extends AppException {
  ImageProcessingException([String? message])
      : super(
          message ?? '이미지 처리에 실패했습니다',
          'IMAGE_ERROR',
        );
}
