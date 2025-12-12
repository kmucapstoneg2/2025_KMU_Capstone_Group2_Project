import 'package:flutter/cupertino.dart';
import 'exceptions.dart';

/// ============================================
/// 에러 핸들러
/// ============================================

class ErrorHandler {
  /// 에러 다이얼로그 표시
  static Future<void> showError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    String message = '알 수 없는 오류가 발생했습니다';

    if (error is AppException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }

    if (!context.mounted) return;

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            CupertinoDialogAction(
              child: const Text('재시도'),
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
            ),
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 에러 로깅
  static void log(dynamic error, [StackTrace? stackTrace]) {
    print('❌ Error: $error');
    if (stackTrace != null) {
      print('📍 StackTrace: $stackTrace');
    }
  }

  /// 에러 처리 (로깅 + 다이얼로그)
  static Future<void> handle(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) async {
    log(error, stackTrace);
    if (context.mounted) {
      await showError(context, error, onRetry: onRetry);
    }
  }
}
