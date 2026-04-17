import 'package:flutter/material.dart';
import '../models/streak.dart';
import '../utils/streak_theme.dart';
import '../services/streak_provider.dart';
import 'package:provider/provider.dart';

class StreakCard extends StatelessWidget {
  final Streak streak;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: StreakSizes.paddingMd,
        vertical: StreakSizes.paddingSm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(StreakSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak.title,
                          style: StreakTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: StreakSizes.paddingSm),
                        Text(
                          streak.description,
                          style: StreakTextStyles.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: StreakSizes.paddingMd),
                  _buildStreakIndicator(),
                ],
              ),
              const SizedBox(height: StreakSizes.paddingMd),
              _buildStreakStats(),
              const SizedBox(height: StreakSizes.paddingMd),
              _buildTodayStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: streak.currentStreak > 0 
          ? StreakColors.fireGradient 
          : StreakColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: streak.currentStreak > 0 
              ? StreakColors.streakFire.withOpacity(0.3)
              : StreakColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            streak.currentStreak > 0 ? Icons.local_fire_department : Icons.emoji_events,
            color: Colors.white,
            size: StreakSizes.iconMd,
          ),
          const SizedBox(height: 2),
          Text(
            '${streak.currentStreak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.emoji_events,
            label: 'En İyi',
            value: '${streak.bestStreak}',
            color: StreakColors.streakSuccess,
          ),
        ),
        const SizedBox(width: StreakSizes.paddingMd),
        Expanded(
          child: _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Toplam Gün',
            value: '${streak.entries.where((e) => e.completed).length}',
            color: StreakColors.primary,
          ),
        ),
        const SizedBox(width: StreakSizes.paddingMd),
        Expanded(
          child: _buildStatItem(
            icon: Icons.trending_up,
            label: 'Başarı',
            value: _getSuccessRate(),
            color: StreakColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: StreakSizes.paddingSm,
        horizontal: StreakSizes.paddingMd,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(StreakSizes.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: StreakSizes.iconSm),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: StreakTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus(BuildContext context) {
    final provider = Provider.of<StreakProvider>(context, listen: false);
    final today = DateTime.now();
    final todayEntry = provider.getEntryForDate(streak.id, today);
    
    if (todayEntry != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: StreakSizes.paddingSm,
          horizontal: StreakSizes.paddingMd,
        ),
        decoration: BoxDecoration(
          color: todayEntry.completed 
            ? StreakColors.completed.withOpacity(0.1)
            : StreakColors.failed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(StreakSizes.radiusSm),
        ),
        child: Row(
          children: [
            Icon(
              todayEntry.completed ? Icons.check_circle : Icons.cancel,
              color: todayEntry.completed ? StreakColors.completed : StreakColors.failed,
              size: StreakSizes.iconSm,
            ),
            const SizedBox(width: StreakSizes.paddingSm),
            Expanded(
              child: Text(
                todayEntry.completed 
                  ? 'Bugün tamamlandı!' 
                  : 'Bugün tamamlanmadı',
                style: StreakTextStyles.bodyMedium.copyWith(
                  color: todayEntry.completed 
                    ? StreakColors.completed 
                    : StreakColors.failed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: StreakSizes.paddingSm,
        horizontal: StreakSizes.paddingMd,
      ),
      decoration: BoxDecoration(
        color: StreakColors.pending.withOpacity(0.1),
        borderRadius: BorderRadius.circular(StreakSizes.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: StreakColors.pending,
            size: StreakSizes.iconSm,
          ),
          const SizedBox(width: StreakSizes.paddingSm),
          Expanded(
            child: Text(
              'Bugün henüz işaretlenmedi',
              style: StreakTextStyles.bodyMedium.copyWith(
                color: StreakColors.pending,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSuccessRate() {
    if (streak.entries.isEmpty) return '0%';
    
    final completed = streak.entries.where((e) => e.completed).length;
    final rate = (completed / streak.entries.length * 100).round();
    return '$rate%';
  }
}
