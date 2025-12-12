import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class WeatherInfoCard extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherInfoCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final weatherData = weather['weather_data'] as Map<String, dynamic>;
    final temperature = weatherData['temperature'];
    final condition = weatherData['condition'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.cloud_sun,
            size: 48,
            color: CupertinoColors.white,
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 날씨',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '$temperature°C, $condition',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
