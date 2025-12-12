import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/closet_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';
import 'closet_add_page.dart';
import 'closet_detail_page.dart';

/// ============================================
/// 옷장 페이지
/// ============================================

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  State<ClosetPage> createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  List<String> filterSeasons = [];
  List<String> filterStyles = [];
  List<String> filterColors = [];
  int selectedTab = 0;

  final List<String> tabs = ["전체", "상의", "하의", "아우터", "원피스", "신발", "위시"];

  Future<void> _showFilterDialog(ClosetProvider provider) async {
    final result = await showCupertinoModalPopup<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilterModal(
        seasons: provider.seasons.map((s) => s['season_name'] as String).toList(),
        styles: provider.styles.map((s) => s['style_name'] as String).toList(),
        colors: provider.colors.map((c) => c['color_name'] as String).toList(),
        selectedSeasons: filterSeasons,
        selectedStyles: filterStyles,
        selectedColors: filterColors,
      ),
    );

    if (result != null) {
      setState(() {
        filterSeasons = result['seasons'] ?? [];
        filterStyles = result['styles'] ?? [];
        filterColors = result['colors'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClosetProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('옷장'),
            ),
            child: const AppLoadingIndicator(),
          );
        }

        if (provider.error != null) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('옷장'),
            ),
            child: ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadClothes(),
            ),
          );
        }

        return CupertinoPageScaffold(
          navigationBar: _buildNavigationBar(provider),
          child: SafeArea(
            child: Column(
              children: [
                if (ClosetFilterLogic.hasActiveFilters(
                  filterSeasons: filterSeasons,
                  filterStyles: filterStyles,
                  filterColors: filterColors,
                ) && selectedTab != 6)
                  FilterTagsBar(
                    filterSeasons: filterSeasons,
                    filterStyles: filterStyles,
                    filterColors: filterColors,
                    onRemoveFilter: (type, value) {
                      setState(() {
                        if (type == 'season') filterSeasons.remove(value);
                        if (type == 'style') filterStyles.remove(value);
                        if (type == 'color') filterColors.remove(value);
                      });
                    },
                    onClearAll: () {
                      setState(() {
                        filterSeasons.clear();
                        filterStyles.clear();
                        filterColors.clear();
                      });
                    },
                  ),
                ClosetTabBar(
                  tabs: tabs,
                  selectedTab: selectedTab,
                  onTabSelected: (index) => setState(() => selectedTab = index),
                ),
                Expanded(
                  child: _buildGrid(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CupertinoNavigationBar _buildNavigationBar(ClosetProvider provider) {
    return CupertinoNavigationBar(
      middle: const Text('옷장'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedTab != 6)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showFilterDialog(provider),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(CupertinoIcons.slider_horizontal_3),
                  if (ClosetFilterLogic.hasActiveFilters(
                    filterSeasons: filterSeasons,
                    filterStyles: filterStyles,
                    filterColors: filterColors,
                  ))
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                                                child: Text(
                          '${ClosetFilterLogic.getFilterCount(
                            filterSeasons: filterSeasons,
                            filterStyles: filterStyles,
                            filterColors: filterColors,
                          )}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const ClosetAddPage(),
                ),
              );
              if (result == true && mounted) {
                context.read<ClosetProvider>().loadClothes();
              }
            },
            child: const Icon(CupertinoIcons.add_circled),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ClosetProvider provider) {
    List<Map<String, dynamic>> items;

    if (selectedTab == 6) {
      // 위시리스트 로드
      items = provider.wishlistClothes;
      
      if (items.isEmpty) {
        return const EmptyState(
          icon: CupertinoIcons.heart,
          message: '좋아요한 옷이 없습니다\n옷 상세 페이지에서 하트를 눌러보세요!',
        );
      }
    } else {
      final category = tabs[selectedTab];
      final categoryFiltered = provider.getClothesByCategory(category);

      items = ClosetFilterLogic.applyFilters(
        items: categoryFiltered,
        category: category,
        filterSeasons: filterSeasons,
        filterStyles: filterStyles,
        filterColors: filterColors,
      );

      if (items.isEmpty) {
        return const EmptyState(
          icon: CupertinoIcons.square_grid_2x2,
          message: '옷이 없습니다',
        );
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 210,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return ClosetItemCard(
          item: item,
          isWishlist: selectedTab == 6,
          onTap: () async {
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ClosetDetailPage(item: item),
              ),
            );

            if (result == true && mounted) {
              context.read<ClosetProvider>().loadClothes();
            }
          },
        );
      },
    );
  }
}

class _FilterModal extends StatefulWidget {
  final List<String> seasons;
  final List<String> styles;
  final List<String> colors;
  final List<String> selectedSeasons;
  final List<String> selectedStyles;
  final List<String> selectedColors;

  const _FilterModal({
    required this.seasons,
    required this.styles,
    required this.colors,
    required this.selectedSeasons,
    required this.selectedStyles,
    required this.selectedColors,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late List<String> seasons;
  late List<String> styles;
  late List<String> colors;

  @override
  void initState() {
    super.initState();
    seasons = List.from(widget.selectedSeasons);
    styles = List.from(widget.selectedStyles);
    colors = List.from(widget.selectedColors);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const Text(
                  '필터',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context, {
                      'seasons': seasons,
                      'styles': styles,
                      'colors': colors,
                    });
                  },
                  child: const Text('적용'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MultiChipSection(
                    title: '계절',
                    items: widget.seasons,
                    selectedValues: seasons,
                    onChanged: (values) => setState(() => seasons = values),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  MultiChipSection(
                    title: '스타일',
                    items: widget.styles,
                    selectedValues: styles,
                    onChanged: (values) => setState(() => styles = values),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  MultiChipSection(
                    title: '색상',
                    items: widget.colors,
                    selectedValues: colors,
                    onChanged: (values) => setState(() => colors = values),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
