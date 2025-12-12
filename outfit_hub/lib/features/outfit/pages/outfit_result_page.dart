import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/error/error_handler.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 코디 추천 결과 페이지
/// ============================================

class OutfitResultPage extends StatefulWidget {
  const OutfitResultPage({super.key});

  @override
  State<OutfitResultPage> createState() => _OutfitResultPageState();
}

class _OutfitResultPageState extends State<OutfitResultPage> {
  Map<String, dynamic>? weather;
  List<Map<String, dynamic>> recommendedClothes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => isLoading = true);

    try {
      final todayWeather = await OutfitRecommendationLogic.getTodayWeather();
      
      if (todayWeather != null) {
        final recommended = await OutfitRecommendationLogic.recommendOutfits(
          weather: todayWeather,
        );

        setState(() {
          weather = todayWeather;
          recommendedClothes = recommended;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        await ErrorHandler.showError(context, e, onRetry: _loadRecommendations);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('코디 추천'),
      ),
      child: SafeArea(
        child: isLoading
            ? const AppLoadingIndicator()
            : weather == null
                ? const EmptyState(
                    icon: CupertinoIcons.cloud,
                    message: '날씨 정보가 없습니다',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WeatherInfoCard(weather: weather!),
                        const SizedBox(height: AppSpacing.xl),
                        const Text(
                          '추천 코디',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (recommendedClothes.isEmpty)
                          const EmptyState(
                            icon: CupertinoIcons.square_grid_2x2,
                            message: '추천할 옷이 없습니다',
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 210,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                            ),
                            itemCount: recommendedClothes.length,
                            itemBuilder: (context, index) {
                              return OutfitRecommendCard(
                                cloth: recommendedClothes[index],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
