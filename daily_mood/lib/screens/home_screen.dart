import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mood_provider.dart';
import '../services/notification_service.dart';
import '../widgets/mood_entry_card.dart';
import '../utils/mood_colors.dart';
import '../utils/date_extensions.dart';
import 'add_entry_screen.dart';
import 'history_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().initialize();
    });
  }

  Future<bool> _getBackgroundServiceStatus() async {
    final notificationService = NotificationService();
    return notificationService.isBackgroundServiceRunning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruh Hali Takibi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MoodColors.textPrimary,
                  ),
            ),
            Text(
              DateTime.now().formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MoodColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.testNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test bildirimi gönderildi!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: MoodColors.textSecondary,
            ),
            tooltip: 'Test Bildirimi',
          ),
          IconButton(
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(
              Icons.settings_outlined,
              color: MoodColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          if (moodProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: MoodColors.accent,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await moodProvider.loadEntries();
            },
            color: MoodColors.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's mood section
                  TodayMoodCard(
                    entry: moodProvider.todayEntry,
                    onAddMood: () => _navigateToAddEntry(context),
                    onEditMood: moodProvider.todayEntry != null
                        ? () => _navigateToAddEntry(context, moodProvider.todayEntry)
                        : null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  _buildQuickActions(context, moodProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Recent entries section
                  if (moodProvider.entries.isNotEmpty)
                    _buildRecentEntries(context, moodProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _getBackgroundServiceStatus(),
        builder: (context, snapshot) {
          final isRunning = snapshot.data ?? false;
          return FloatingActionButton(
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.toggleBackgroundService();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isRunning 
                        ? 'Arka plan servisi durduruldu!' 
                        : 'Arka plan servisi başlatıldı!'),
                    backgroundColor: MoodColors.accent,
                  ),
                );
              }
              setState(() {}); // Refresh the UI
            },
            backgroundColor: isRunning ? Colors.red : Colors.green,
            tooltip: isRunning ? 'Arka Plan Servisini Durdur' : 'Arka Plan Servisini Başlat',
            child: Icon(
              isRunning ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, MoodProvider moodProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context: context,
            title: 'Geçmiş',
            subtitle: '${moodProvider.entries.length} kayıt',
            icon: Icons.history,
            color: MoodColors.accent,
            onTap: () => _navigateToHistory(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            title: 'Analiz',
            subtitle: 'Haftalık görünüm',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF10B981),
            onTap: () => _navigateToAnalysis(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MoodColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MoodColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MoodColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, MoodProvider moodProvider) {
    final recentEntries = moodProvider.entries.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Kayıtlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: MoodColors.textPrimary,
                  ),
            ),
            TextButton(
              onPressed: () => _navigateToHistory(context),
              child: Text(
                'Tümünü Gör',
                style: TextStyle(
                  color: MoodColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentEntries.map((entry) => MoodEntryCard(
              entry: entry,
              compact: true,
              onTap: () => _navigateToAddEntry(context, entry),
              onDelete: () => _confirmDeleteEntry(context, entry.id),
            )),
        if (recentEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: MoodColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MoodColors.textSecondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.mood_outlined,
                  size: 48,
                  color: MoodColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz kayıt yok',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MoodColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk ruh hali kaydınızı ekleyin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MoodColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _navigateToAddEntry(BuildContext context, [dynamic entry]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(existingEntry: entry),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  void _navigateToAnalysis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnalysisScreen(),
      ),
    );
  }

  void _confirmDeleteEntry(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kaydı Sil'),
          content: const Text('Bu ruh hali kaydını silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MoodProvider>().deleteMoodEntry(entryId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kayıt silindi'),
                    backgroundColor: MoodColors.accent,
                  ),
                );
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ayarlar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Bildirimler'),
                subtitle: const Text('Saat başı hatırlatma bildirimi (08:00-23:00)'),
                trailing: FutureBuilder<bool>(
                  future: NotificationService().areNotificationsEnabled(),
                  builder: (context, snapshot) {
                    return Switch(
                      value: snapshot.data ?? false,
                      onChanged: (value) async {
                        final notificationService = NotificationService();
                        await notificationService.setNotificationsEnabled(value);
                        
                        if (value) {
                          final granted = await notificationService.requestPermissions();
                          if (granted) {
                            await notificationService.scheduleExactDailyNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bildirimler aktifleştirildi'),
                                backgroundColor: MoodColors.accent,
                              ),
                            );
                          }
                        } else {
                          await notificationService.cancelAllScheduledNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bildirimler deaktifleştirildi'),
                              backgroundColor: MoodColors.accent,
                            ),
                          );
                        }
                        setState(() {}); // Refresh to update switch state
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Bildirimleri Yenile'),
                subtitle: const Text('Bildirim planlamasını yeniden başlat'),
                onTap: () async {
                  final notificationService = NotificationService();
                  await notificationService.scheduleExactDailyNotifications();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bildirimler yeniden planlandı!'),
                        backgroundColor: MoodColors.accent,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Arka Plan Servisi'),
                subtitle: FutureBuilder<bool>(
                  future: _getBackgroundServiceStatus(),
                  builder: (context, snapshot) {
                    final isRunning = snapshot.data ?? false;
                    return Text(isRunning 
                        ? 'Arka planda çalışıyor (Saat başı bildirim)' 
                        : 'Durduruldu - Çalıştırmak için dokunun');
                  },
                ),
                trailing: FutureBuilder<bool>(
                  future: _getBackgroundServiceStatus(),
                  builder: (context, snapshot) {
                    final isRunning = snapshot.data ?? false;
                    return Switch(
                      value: isRunning,
                      onChanged: (value) async {
                        final notificationService = NotificationService();
                        await notificationService.toggleBackgroundService();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value 
                                  ? 'Arka plan servisi başlatıldı!' 
                                  : 'Arka plan servisi durduruldu!'),
                              backgroundColor: MoodColors.accent,
                            ),
                          );
                        }
                        setState(() {}); // Refresh the UI
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Bildirim Durumu'),
                subtitle: FutureBuilder<List<dynamic>>(
                  future: NotificationService().getPendingNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final count = snapshot.data!.length;
                      return Text('$count bekleyen bildirim');
                    }
                    return const Text('Kontrol ediliyor...');
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notification_add),
                title: const Text('Test Bildirimi'),
                subtitle: const Text('Bildirim sistemini test et'),
                onTap: () async {
                  await NotificationService().testNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test bildirimi gönderildi!'),
                        backgroundColor: MoodColors.accent,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Tüm Verileri Sil'),
                subtitle: const Text('Dikkat: Bu işlem geri alınamaz'),
                onTap: () => _confirmClearAllData(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAllData(BuildContext context) {
    Navigator.of(context).pop(); // Close settings dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tüm Verileri Sil'),
          content: const Text(
            'Bu işlem tüm ruh hali kayıtlarınızı silecektir. Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MoodProvider>().clearAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm veriler silindi'),
                    backgroundColor: MoodColors.accent,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
