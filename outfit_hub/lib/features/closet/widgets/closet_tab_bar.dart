import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 옷장 탭바
/// ============================================

class ClosetTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const ClosetTabBar({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedTab == index;
          final isWishlist = tabs[index] == '위시';

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isWishlist ? AppColors.wishlist : AppColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? CupertinoColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
