import 'package:flutter/cupertino.dart';

/// ============================================
/// 로딩 오버레이
/// ============================================

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: CupertinoColors.black.withOpacity(0.3),
            child: Center(
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
                      Text(message!),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
