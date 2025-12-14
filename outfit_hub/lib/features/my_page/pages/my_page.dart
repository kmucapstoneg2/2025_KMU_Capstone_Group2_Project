import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';
import 'edit_profile_page.dart';

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
  String? errorMessage; // 에러 메시지 저장

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      // 게스트인 경우
      if (authProvider.isGuest) {
        setState(() {
          user = {
            'username': '게스트',
            'email': '게스트 계정',
            'region': '서울',
          };
        });
      } 
      // 로그인한 경우: 서버에서 프로필 정보 가져오기
      else if (authProvider.isLoggedIn && authProvider.accessToken != null) {
        final profile = await ProfileService.getProfile(
          token: authProvider.accessToken!,
        );
        setState(() {
          user = {
            'username': profile.username,
            'email': profile.email,
            'region': profile.region ?? '서울',
            'profileImageUrl': profile.profileImageUrl,
          };
        });
      } else {
        throw ApiException('로그인이 필요합니다', 401);
      }
      
      final userStats = await ProfileLogic.getStats();
      setState(() {
        stats = userStats;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '서버 연결 실패: ${e.message}';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '서버에 연결할 수 없습니다.\n백엔드 서버가 실행 중인지 확인해주세요.';
      });
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

  Future<void> _handleLogout() async {
    final confirmed = await DialogHelper.showConfirm(
      context,
      title: '로그아웃',
      content: '로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
    );

    if (!confirmed) return;

    try {
      await context.read<AuthProvider>().logout();
      // AuthWrapper가 상태 변경을 감지하여 자동으로 로그인 페이지로 이동
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isGuest) {
      await DialogHelper.showAlert(
        context,
        title: '알림',
        content: '프로필 수정은 로그인 후 사용할 수 있습니다.',
      );
      return;
    }
    
    if (user == null) return;
    
    final result = await Navigator.push<bool>(
      context,
      CupertinoPageRoute(
        builder: (context) => EditProfilePage(currentProfile: user!),
      ),
    );
    
    // 프로필 수정 후 데이터 새로고침
    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _handleRegionChange() async {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isGuest) {
      await DialogHelper.showAlert(
        context,
        title: '알림',
        content: '지역 설정은 로그인 후 사용할 수 있습니다.',
      );
      return;
    }
    
    await _navigateToEditProfile();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.wifi_slash,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            CupertinoButton.filled(
              onPressed: _loadData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isGuest = authProvider.isGuest;
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('마이페이지'),
      ),
      child: SafeArea(
        child: isLoading
            ? const AppLoadingIndicator()
            : errorMessage != null
                ? _buildErrorView()
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
                            ProfileCard(
                              user: user!,
                              onEditTap: isGuest ? null : _navigateToEditProfile,
                            ),
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
                                    onTap: _navigateToEditProfile,
                                  ),
                                  SettingItem(
                                icon: CupertinoIcons.location,
                                title: '지역 설정',
                                subtitle: user!['region'] as String,
                                onTap: _handleRegionChange,
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
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 계정 섹션
                        const Text(
                          '계정',
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
                              if (isGuest) ...[
                                SettingItem(
                                  icon: CupertinoIcons.person_add,
                                  title: '로그인 / 회원가입',
                                  subtitle: '계정을 만들어 데이터를 안전하게 보관하세요',
                                  onTap: () async {
                                    // 로그아웃하면 AuthWrapper가 자동으로 로그인 페이지로 이동
                                    await context.read<AuthProvider>().logout();
                                  },
                                ),
                              ] else ...[
                                SettingItem(
                                  icon: CupertinoIcons.square_arrow_right,
                                  title: '로그아웃',
                                  iconColor: CupertinoColors.systemRed,
                                  onTap: _handleLogout,
                                ),
                              ],
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
