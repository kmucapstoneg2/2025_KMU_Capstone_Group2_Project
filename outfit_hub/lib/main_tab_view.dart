import 'package:flutter/cupertino.dart';
import 'core/theme/theme.dart';
import 'features/home/pages/home_page.dart';
import 'features/closet/pages/closet_page.dart';
import 'features/calendar/pages/calendar_page.dart';
import 'features/community/pages/community_page.dart';
import 'features/my_page/pages/my_page.dart';

/// ============================================
/// 메인 탭 뷰
/// ============================================

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => MainTabViewState();
}

class MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ClosetPage(),
    const CalendarPage(),
    const CommunityPage(),
    const MyPage(),
  ];

  void changeTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(0, CupertinoIcons.home, '홈'),
                    _buildTabItem(1, CupertinoIcons.square_grid_2x2, '옷장'),
                    _buildTabItem(2, CupertinoIcons.calendar, '캘린더'),
                    _buildTabItem(3, CupertinoIcons.person_2, '커뮤니티'),
                    _buildTabItem(4, CupertinoIcons.person, '마이'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: CupertinoColors.systemBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
