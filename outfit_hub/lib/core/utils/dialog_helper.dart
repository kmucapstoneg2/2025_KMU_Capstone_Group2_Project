import 'package:flutter/cupertino.dart';

/// ============================================
/// 다이얼로그 헬퍼
/// ============================================

class DialogHelper {
  /// 확인 다이얼로그
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text(cancelText),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(confirmText),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 삭제 확인 다이얼로그
  static Future<bool> showDeleteConfirm(
    BuildContext context, {
    String title = '삭제하시겠습니까?',
    String content = '이 작업은 되돌릴 수 없습니다.',
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('삭제'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 알림 다이얼로그
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = '확인',
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text(buttonText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 성공 다이얼로그
  static Future<void> showSuccess(
    BuildContext context, {
    String title = '완료',
    required String content,
    VoidCallback? onConfirm,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  static void showLoading(BuildContext context, {String? message}) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 15),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 다이얼로그 닫기
  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  /// 선택 다이얼로그
  static Future<T?> showPicker<T>(
    BuildContext context, {
    required List<T> items,
    required String Function(T) itemBuilder,
    T? initialItem,
  }) async {
    return await showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                                        onPressed: () => Navigator.pop(context),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: initialItem != null
                      ? items.indexOf(initialItem)
                      : 0,
                ),
                onSelectedItemChanged: (index) {
                  Navigator.pop(context, items[index]);
                },
                children: items.map((item) {
                  return Center(
                    child: Text(itemBuilder(item)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
