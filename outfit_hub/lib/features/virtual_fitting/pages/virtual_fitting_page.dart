import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 가상 피팅 페이지
/// ============================================

class VirtualFittingPage extends StatelessWidget {
  const VirtualFittingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('가상 피팅'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.person_crop_square,
                size: 100,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                '가상 피팅',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'AI 기술을 활용한 가상 피팅 서비스',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const InfoBanner(),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: '준비중',
                onPressed: null,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
