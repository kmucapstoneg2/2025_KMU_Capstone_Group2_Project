import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../main.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';
import '../../closet/pages/closet_add_page.dart';
import '../../virtual_fitting/pages/virtual_fitting_page.dart';
import '../../notification/views/notification_list_view.dart';

/// ============================================
/// 홈 페이지
/// ============================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? weather;
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> recentOutfits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        HomeLogic.getTodayWeather(),
        HomeLogic.getTodaySchedules(),
        HomeLogic.getRecentOutfits(limit: 3),
      ]);

      setState(() {
        weather = results[0] as Map<String, dynamic>?;
        schedules = results[1] as List<Map<String, dynamic>>;
        recentOutfits = results[2] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        await ErrorHandler.showError(context, e, onRetry: _loadData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const Text(
          'Outfit Hub',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 테스트 알림 추가 버튼
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<NotificationProvider>().addDummyNotification();
              },
              child: const Icon(CupertinoIcons.add_circled, size: 24),
            ),
            // 알림 아이콘 버튼
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const NotificationListView(),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.bell, size: 24),
                      ),
                      if (provider.hasUnread)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const AppLoadingIndicator()
            : CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: _loadData,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          WeatherCard(weather: weather),
                          const SizedBox(height: AppSpacing.lg),
                          _buildQuickActions(),
                          const SizedBox(height: AppSpacing.lg),
                          ScheduleSummaryCard(
                            schedules: schedules,
                            onTap: () {
                              mainTabKey.currentState?.changeTab(2);
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          RecentOutfitCard(
                            outfits: recentOutfits,
                            onTap: () {
                              mainTabKey.currentState?.changeTab(2);
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final username = userProvider.username;
        final now = DateTime.now();
        final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$username님 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            icon: CupertinoIcons.add_circled_solid,
            label: '옷 추가',
            onTap: () async {
              final result = await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const ClosetAddPage(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickActionButton(
            icon: CupertinoIcons.person_crop_square,
            label: '가상 피팅',
            color: AppColors.primaryDark,
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const VirtualFittingPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
