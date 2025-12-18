import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/storage.dart';
import '../../../providers/auth_provider.dart';
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
  WeatherData? weather;
  List<Map<String, dynamic>> recommendedClothes = [];
  String? reason;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAndHandleToken();
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('로그인이 필요합니다. 다시 로그인해주세요.');
      }

      final now = DateTime.now();
      final todayKey = DateHelper.toDateKey(now);
      final schedules = await Storage.getSchedulesByDate(todayKey);
      final primarySchedule = schedules.isNotEmpty ? schedules.first : null;

      final location = (primarySchedule?['location'] as String?) ?? authProvider.region ?? '서울';
      final time = (primarySchedule?['time'] as String?) ?? DateHelper.formatTime(now);
      final tags = (primarySchedule?['tags'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      final recommendation = await RecommendationService.getOutfitRecommendation(
        date: todayKey,
        time: time,
        location: location,
        tags: tags,
        token: token,
      );

      WeatherData? weatherData;
      try {
        weatherData = await WeatherService.getWeather(location);
      } catch (_) {
        weatherData = null;
      }

      final data = recommendation['data'] as Map<String, dynamic>? ?? {};
      final items = (data['recommended_items'] as List?)
              ?.map((e) => (e as Map).map((key, value) => MapEntry(key.toString(), value)))
              .toList() ??
          <Map<String, dynamic>>[];

      setState(() {
        weather = weatherData;
        reason = data['reason'] as String?;
        recommendedClothes = items;
        isLoading = false;
      });
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (weather != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          '${weather!.location} 현재 ${weather!.temperature.toStringAsFixed(1)}°C / ${weather!.description}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (reason != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reason!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
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
