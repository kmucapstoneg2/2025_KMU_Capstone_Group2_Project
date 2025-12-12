import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 날씨 카드
/// ============================================

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weather;

  const WeatherCard({
    super.key,
    this.weather,
  });

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.cloud_sun,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '날씨 정보 없음',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final weatherData = weather!['weather_data'] as Map<String, dynamic>;
    final temperature = weatherData['temperature'] ?? 0;
    final condition = weatherData['condition'] ?? '알 수 없음';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(condition),
            color: CupertinoColors.white,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature°C',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                condition,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.contains('맑음')) {
      return CupertinoIcons.sun_max_fill;
    } else if (condition.contains('흐림')) {
      return CupertinoIcons.cloud_fill;
    } else if (condition.contains('비')) {
      return CupertinoIcons.cloud_rain_fill;
    } else if (condition.contains('눈')) {
      return CupertinoIcons.snow;
    }
    return CupertinoIcons.cloud_sun_fill;
  }
}
