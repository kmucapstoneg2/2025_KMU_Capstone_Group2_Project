import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '가상 피팅 기능은 준비중입니다.\nAI 모델 연동 후 제공될 예정입니다.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
