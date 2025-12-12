import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/user_provider.dart';
import 'logic/logic.dart';
import 'widgets/widgets.dart';

/// ============================================
/// 마이페이지
/// ============================================

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, dynamic>? user;
  Map<String, int> stats = {'clothCount': 0, 'outfitCount': 0};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final userInfo = await ProfileLogic.getUserInfo();
      final userStats = await ProfileLogic.getStats();

      setState(() {
        user = userInfo;
        stats = userStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        await ErrorHandler.showError(context, e, onRetry: _loadData);
      }
    }
  }

  Future<void> _clearData() async {
    final confirmed = await DialogHelper.showDeleteConfirm(
      context,
      title: '모든 데이터를 삭제하시겠습니까?',
      content: '이 작업은 되돌릴 수 없습니다.',
    );

    if (!confirmed) return;

    DialogHelper.showLoading(context);

    try {
      await ProfileLogic.clearAllData();

      if (mounted) {
        DialogHelper.hideLoading(context);
        await context.read<UserProvider>().loadUserData();
        await _loadData();

        await DialogHelper.showSuccess(
          context,
          content: '모든 데이터가 삭제되었습니다',
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.hideLoading(context);
        await ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('마이페이지'),
      ),
      child: SafeArea(
        child: isLoading
            ? const AppLoadingIndicator()
            : user == null
                ? const EmptyState(
                    icon: CupertinoIcons.person,
                    message: '사용자 정보를 불러올 수 없습니다',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileCard(user: user!),

                        const SizedBox(height: AppSpacing.lg),

                        StatsCard(stats: stats),

                        const SizedBox(height: AppSpacing.xl),

                        const Text(
                          '설정',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                icon: CupertinoIcons.person,
                                title: '프로필 수정',
                                subtitle: '이름, 프로필 사진 변경',
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.location,
                                title: '지역 설정',
                                subtitle: user!['region'] as String,
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.bell,
                                title: '알림 설정',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        const Text(
                          '데이터 관리',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                icon: CupertinoIcons.arrow_down_doc,
                                title: '데이터 백업',
                                subtitle: '내 데이터 백업하기',
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.arrow_up_doc,
                                title: '데이터 복원',
                                subtitle: '백업된 데이터 복원하기',
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.trash,
                                title: '모든 데이터 삭제',
                                subtitle: '앱의 모든 데이터를 삭제합니다',
                                iconColor: CupertinoColors.systemRed,
                                onTap: _clearData,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        const Text(
                          '정보',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                icon: CupertinoIcons.info_circle,
                                title: '앱 정보',
                                subtitle: 'v1.0.0',
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.doc_text,
                                title: '이용약관',
                                onTap: () {},
                              ),
                              SettingItem(
                                icon: CupertinoIcons.lock_shield,
                                title: '개인정보처리방침',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
      ),
    );
  }
}
