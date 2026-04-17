import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/streak.dart';
import '../services/streak_provider.dart';
import '../utils/streak_theme.dart';

class StreakDetailScreen extends StatefulWidget {
  final Streak streak;

  const StreakDetailScreen({
    super.key,
    required this.streak,
  });

  @override
  State<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  late Streak currentStreak;

  @override
  void initState() {
    super.initState();
    currentStreak = widget.streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreakColors.background,
      body: Consumer<StreakProvider>(
        builder: (context, provider, child) {
          // Get updated streak from provider
          final updatedStreak = provider.streaks.firstWhere(
            (s) => s.id == currentStreak.id,
            orElse: () => currentStreak,
          );
          currentStreak = updatedStreak;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(StreakSizes.paddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakStats(),
                      const SizedBox(height: StreakSizes.paddingXl),
                      _buildTodayAction(provider),
                      const SizedBox(height: StreakSizes.paddingXl),
                      _buildRecentHistory(provider),
                      const SizedBox(height: StreakSizes.paddingXl),
                      _buildCalendarView(provider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: StreakColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, context),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: StreakColors.streakDanger),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: StreakColors.streakDanger)),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: StreakColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              StreakSizes.paddingLg,
              StreakSizes.paddingXl * 2,
              StreakSizes.paddingLg,
              StreakSizes.paddingLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(StreakSizes.paddingMd),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentStreak.currentStreak > 0 
                          ? Icons.local_fire_department 
                          : Icons.emoji_events,
                        color: Colors.white,
                        size: StreakSizes.iconLg,
                      ),
                    ),
                    const SizedBox(width: StreakSizes.paddingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStreak.title,
                            style: StreakTextStyles.heading2.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: StreakSizes.paddingSm),
                          Text(
                            currentStreak.description,
                            style: StreakTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakStats() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StreakSizes.paddingLg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Mevcut Streak',
                    value: '${currentStreak.currentStreak}',
                    subtitle: 'gün',
                    color: StreakColors.streakFire,
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: StreakSizes.paddingMd),
                Expanded(
                  child: _buildStatCard(
                    title: 'En İyi Streak',
                    value: '${currentStreak.bestStreak}',
                    subtitle: 'gün',
                    color: StreakColors.streakSuccess,
                    icon: Icons.emoji_events,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StreakSizes.paddingMd),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Toplam Başarı',
                    value: '${currentStreak.entries.where((e) => e.completed).length}',
                    subtitle: 'gün',
                    color: StreakColors.primary,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: StreakSizes.paddingMd),
                Expanded(
                  child: _buildStatCard(
                    title: 'Başarı Oranı',
                    value: _getSuccessRate(),
                    subtitle: '%',
                    color: StreakColors.accent,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(StreakSizes.paddingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: StreakSizes.iconMd),
          const SizedBox(height: StreakSizes.paddingSm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: StreakTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: StreakSizes.paddingSm),
          Text(
            title,
            style: StreakTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAction(StreakProvider provider) {
    final today = DateTime.now();
    final todayEntry = provider.getEntryForDate(currentStreak.id, today);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StreakSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugün (${DateFormat('dd MMMM yyyy', 'tr_TR').format(today)})',
              style: StreakTextStyles.heading3,
            ),
            const SizedBox(height: StreakSizes.paddingMd),
            if (todayEntry != null)
              _buildTodayStatus(todayEntry)
            else
              _buildTodayActions(provider, today),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatus(StreakEntry entry) {
    return Container(
      padding: const EdgeInsets.all(StreakSizes.paddingMd),
      decoration: BoxDecoration(
        color: entry.completed 
          ? StreakColors.completed.withOpacity(0.1)
          : StreakColors.failed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            entry.completed ? Icons.check_circle : Icons.cancel,
            color: entry.completed ? StreakColors.completed : StreakColors.failed,
            size: StreakSizes.iconLg,
          ),
          const SizedBox(width: StreakSizes.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.completed ? 'Tamamlandı!' : 'Tamamlanmadı',
                  style: StreakTextStyles.bodyLarge.copyWith(
                    color: entry.completed ? StreakColors.completed : StreakColors.failed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!entry.completed && entry.failureReason != null) ...[
                  const SizedBox(height: StreakSizes.paddingSm),
                  Text(
                    'Sebep: ${entry.failureReason}',
                    style: StreakTextStyles.bodyMedium.copyWith(
                      color: StreakColors.failed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActions(StreakProvider provider, DateTime today) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _markDay(provider, today, true),
            icon: const Icon(Icons.check),
            label: const Text('Yaptım'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StreakColors.completed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: StreakSizes.paddingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: StreakSizes.paddingMd),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showFailureDialog(provider, today),
            icon: const Icon(Icons.close),
            label: const Text('Yapmadım'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StreakColors.failed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: StreakSizes.paddingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(StreakProvider provider) {
    final recentEntries = provider.getRecentEntries(currentStreak.id, days: 7);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StreakSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 7 Gün',
              style: StreakTextStyles.heading3,
            ),
            const SizedBox(height: StreakSizes.paddingMd),
            if (recentEntries.isEmpty)
              Text(
                'Henüz kayıt yok',
                style: StreakTextStyles.bodyMedium.copyWith(
                  color: StreakColors.textSecondary,
                ),
              )
            else
              Column(
                children: recentEntries.map((entry) => _buildHistoryItem(entry)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(StreakEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StreakSizes.paddingSm),
      child: Row(
        children: [
          Icon(
            entry.completed ? Icons.check_circle : Icons.cancel,
            color: entry.completed ? StreakColors.completed : StreakColors.failed,
          ),
          const SizedBox(width: StreakSizes.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy - EEEE', 'tr_TR').format(entry.date),
                  style: StreakTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!entry.completed && entry.failureReason != null)
                  Text(
                    entry.failureReason!,
                    style: StreakTextStyles.bodySmall.copyWith(
                      color: StreakColors.failed,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            entry.completed ? 'Başarılı' : 'Başarısız',
            style: StreakTextStyles.caption.copyWith(
              color: entry.completed ? StreakColors.completed : StreakColors.failed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(StreakProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(StreakSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu Ay',
              style: StreakTextStyles.heading3,
            ),
            const SizedBox(height: StreakSizes.paddingMd),
            _buildMiniCalendar(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(StreakProvider provider) {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    return Column(
      children: [
        // Month header
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(now),
          style: StreakTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = DateTime(now.year, now.month, day);
            final entry = provider.getEntryForDate(currentStreak.id, date);
            
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getCalendarDayColor(entry, date, now),
                borderRadius: BorderRadius.circular(StreakSizes.radiusSm),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: _getCalendarDayTextColor(entry, date, now),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(StreakColors.completed, 'Başarılı'),
            _buildLegendItem(StreakColors.failed, 'Başarısız'),
            _buildLegendItem(StreakColors.pending, 'Bugün'),
            _buildLegendItem(StreakColors.surfaceVariant, 'Kayıt yok'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: StreakTextStyles.caption,
        ),
      ],
    );
  }

  Color _getCalendarDayColor(StreakEntry? entry, DateTime date, DateTime now) {
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return StreakColors.pending;
    }
    if (entry == null) return StreakColors.surfaceVariant;
    return entry.completed ? StreakColors.completed : StreakColors.failed;
  }

  Color _getCalendarDayTextColor(StreakEntry? entry, DateTime date, DateTime now) {
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return Colors.white;
    }
    if (entry == null) return StreakColors.textSecondary;
    return Colors.white;
  }

  String _getSuccessRate() {
    if (currentStreak.entries.isEmpty) return '0';
    
    final completed = currentStreak.entries.where((e) => e.completed).length;
    final rate = (completed / currentStreak.entries.length * 100).round();
    return '$rate';
  }

  void _markDay(StreakProvider provider, DateTime date, bool completed) async {
    final success = await provider.markDay(
      streakId: currentStreak.id,
      date: date,
      completed: completed,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(completed ? 'Harika! Streak devam ediyor! 🔥' : 'Kayıt edildi'),
          backgroundColor: completed ? StreakColors.completed : StreakColors.failed,
        ),
      );
    }
  }

  void _showFailureDialog(StreakProvider provider, DateTime date) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neden tamamlayamadın?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'İsteğe bağlı olarak neden tamamlayamadığını belirtebilirsin. Bu sana gelecekte daha iyi planlama yapman için yardımcı olabilir.',
            ),
            const SizedBox(height: StreakSizes.paddingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Sebep (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.markDay(
                streakId: currentStreak.id,
                date: date,
                completed: false,
                failureReason: reasonController.text.trim().isEmpty 
                  ? null 
                  : reasonController.text.trim(),
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kayıt edildi. Yarın tekrar dene! 💪'),
                    backgroundColor: StreakColors.accent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StreakColors.failed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak\'i Sil'),
        content: Text(
          '"${currentStreak.title}" streak\'ini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = Provider.of<StreakProvider>(context, listen: false);
              final success = await provider.deleteStreak(currentStreak.id);
              
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Streak silindi'),
                    backgroundColor: StreakColors.streakDanger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StreakColors.streakDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
