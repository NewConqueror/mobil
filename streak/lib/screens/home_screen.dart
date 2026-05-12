import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/streak_provider.dart';
import '../services/notification_service.dart';
import '../utils/streak_theme.dart';
import '../widgets/streak_card.dart';
import 'add_streak_screen.dart';
import 'streak_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<bool> _getBackgroundServiceStatus() async {
    final notificationService = NotificationService();
    return await notificationService.getBackgroundServiceEnabled();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreakColors.background,
      appBar: AppBar(
        title: const Text(
          'Streak Takip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: StreakColors.textOnPrimary,
          ),
        ),
        backgroundColor: StreakColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: StreakColors.textOnPrimary,
            ),
            onPressed: () => _showNotificationTestDialog(),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: StreakColors.textOnPrimary,
            ),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<StreakProvider>(
        builder: (context, provider, child) {
          final activeStreaks = provider.activeStreaks;
          
          if (activeStreaks.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: activeStreaks.length,
              itemBuilder: (context, index) {
                final streak = activeStreaks[index];
                return StreakCard(
                  streak: streak,
                  onTap: () => _navigateToStreakDetail(streak),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddStreak(),
        backgroundColor: StreakColors.accent,
        child: const Icon(
          Icons.add,
          color: StreakColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: StreakColors.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'İlk Streak\'ini Oluştur!',
              style: StreakTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Hedeflerini belirle ve her gün ilerleme kaydet.',
              style: StreakTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddStreak(),
              icon: const Icon(Icons.add),
              label: const Text('Streak Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StreakColors.accent,
                foregroundColor: StreakColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddStreak() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddStreakScreen()),
    );
    
    if (result == true && mounted) {
      final provider = Provider.of<StreakProvider>(context, listen: false);
      await provider.refreshStreaks();
    }
  }

  void _navigateToStreakDetail(streak) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StreakDetailScreen(streak: streak),
      ),
    );
  }

  void _showNotificationTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Testi'),
        content: const Text('Test bildirimi göndermek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await NotificationService().testNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test bildirimi gönderildi!')),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) async {
    final notificationService = NotificationService();
    final initialNotificationsEnabled =
        await notificationService.areNotificationsEnabled();
    final initialBackgroundRunning =
      await notificationService.getBackgroundServiceEnabled();

    if (!context.mounted) return;

    bool notificationsEnabled = initialNotificationsEnabled;
    bool backgroundRunning = initialBackgroundRunning;
    bool backgroundBusy = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildSwitchRow({
              required IconData icon,
              required String title,
              required String subtitle,
              required bool value,
              required ValueChanged<bool> onChanged,
            }) {
              return InkWell(
                onTap: () => onChanged(!value),
                borderRadius: BorderRadius.circular(StreakSizes.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: StreakSizes.iconSm,
                        color: StreakColors.iconPrimary,
                      ),
                      const SizedBox(width: 12),
                             Expanded(
                               child: InkWell(
                                 onTap: () => onChanged(!value),
                                 borderRadius: BorderRadius.circular(
                                   StreakSizes.radiusSm,
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.symmetric(vertical: 2),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         title,
                                         style: StreakTextStyles.bodyLarge.copyWith(
                                           fontWeight: FontWeight.w600,
                                         ),
                                       ),
                                       const SizedBox(height: 4),
                                       Text(
                                         subtitle,
                                         style: StreakTextStyles.bodySmall,
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                      Switch(
                        value: value,
                        activeThumbColor: StreakColors.accent,
                        onChanged: onChanged,
                      ),
                    ],
                  ),
                ),
              );
            }

            Future<void> toggleBackgroundService() async {
              if (backgroundBusy) return;
              backgroundBusy = true;
              setDialogState(() {});

              await notificationService.toggleBackgroundService();
              backgroundRunning =
                  await notificationService.getBackgroundServiceEnabled();

              backgroundBusy = false;
              setDialogState(() {});
              setState(() {});
            }

            return AlertDialog(
              title: const Text(
                'Ayarlar',
                style: StreakTextStyles.heading3,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      buildSwitchRow(
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                        subtitle:
                            'Saat başı hatırlatma bildirimi (08:00-23:00)',
                        value: notificationsEnabled,
                        onChanged: (value) async {
                          notificationsEnabled = value;
                          setDialogState(() {});
                          setState(() {
                            _notificationsEnabled = value;
                          });

                          await notificationService
                              .setNotificationsEnabled(value);

                          if (value) {
                            final granted =
                                await notificationService.requestPermissions();
                            if (granted) {
                              await notificationService
                                  .scheduleExactDailyNotifications();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bildirimler aktifleştirildi'),
                                    backgroundColor: StreakColors.accent,
                                  ),
                                );
                              }
                            }
                          } else {
                            await notificationService
                                .cancelAllScheduledNotifications();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bildirimler deaktifleştirildi'),
                                  backgroundColor: StreakColors.accent,
                                ),
                              );
                            }
                          }

                          backgroundRunning =
                              await notificationService
                                .getBackgroundServiceEnabled();
                          setDialogState(() {});
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Bildirimleri Yenile'),
                        subtitle:
                            const Text('Bildirim planlamasını yeniden başlat'),
                        onTap: () async {
                          await notificationService
                              .scheduleExactDailyNotifications();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bildirimler yeniden planlandı!'),
                                backgroundColor: StreakColors.accent,
                              ),
                            );
                          }
                        },
                      ),
                      buildSwitchRow(
                        icon: Icons.play_circle_outline,
                        title: 'Arka Plan Servisi',
                        subtitle: backgroundRunning
                            ? 'Arka planda çalışıyor (Saat başı bildirim)'
                            : 'Durduruldu - Çalıştırmak için dokunun',
                        value: backgroundRunning,
                        onChanged: (value) async {
                          if (!notificationsEnabled) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Önce bildirimleri açın'),
                                  backgroundColor: StreakColors.accent,
                                ),
                              );
                            }
                            return;
                          }
                          await toggleBackgroundService();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  backgroundRunning
                                      ? 'Arka plan servisi başlatıldı!'
                                      : 'Arka plan servisi durduruldu!',
                                ),
                                backgroundColor: StreakColors.accent,
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Bildirim Durumu'),
                        subtitle: FutureBuilder<List<dynamic>>(
                          future: notificationService.getPendingNotifications(),
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
                          await notificationService.testNotification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Test bildirimi gönderildi!'),
                                backgroundColor: StreakColors.accent,
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Hakkında'),
                        subtitle: const Text('Streak Takip v1.0.0'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Kapat',
                    style: TextStyle(color: StreakColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Streak Takip',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: StreakColors.accentGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_fire_department,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'Alışkanlıklarını takip et, hedeflerine ulaş!\n\n'
          'Bu uygulama ile günlük hedeflerini belirleyebilir, '
          'streak\'lerini takip edebilir ve başarılarını görselleştirebilirsin.',
        ),
      ],
    );
  }
}