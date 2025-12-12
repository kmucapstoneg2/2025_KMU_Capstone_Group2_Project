import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class StatsCard extends StatelessWidget {
  final Map<String, int> stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.square_grid_2x2,
              label: '보유 옷',
              value: '${stats['clothCount']}개',
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.photo_on_rectangle,
              label: '저장 코디',
              value: '${stats['outfitCount']}개',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
