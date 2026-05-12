import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/mood_provider.dart';
import '../models/mood_entry.dart';
import '../models/mood.dart';
import '../utils/mood_colors.dart';
import '../utils/date_extensions.dart';

class _MoodStat {
  final String id;
  final String emoji;
  final String name;
  final Color color;
  final bool isCustom;
  int count;

  _MoodStat({
    required this.id,
    required this.emoji,
    required this.name,
    required this.color,
    required this.isCustom,
    this.count = 0,
  });
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedPeriod = 'this_week'; // this_week, this_month, all_time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: MoodColors.textPrimary,
          ),
        ),
        title: const Text(
          'Ruh Hali Analizi',
          style: TextStyle(
            color: MoodColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showPeriodSelector,
            icon: const Icon(
              Icons.date_range,
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

          final analysisData = _getAnalysisData(moodProvider);
          final totalCount = analysisData.fold<int>(
            0,
            (sum, stat) => sum + stat.count,
          );

          if (totalCount == 0) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period info
                _buildPeriodInfo(),
                
                const SizedBox(height: 24),
                
                // Main chart
                _buildMoodChart(analysisData),
                
                const SizedBox(height: 24),
                
                // Statistics cards
                _buildStatisticsCards(analysisData),
                
                const SizedBox(height: 24),
                
                // Mood breakdown
                _buildMoodBreakdown(analysisData),
                
                const SizedBox(height: 24),
                
                // Insights
                _buildInsights(analysisData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodInfo() {
    String periodText;
    switch (_selectedPeriod) {
      case 'this_week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        periodText = '${startOfWeek.shortFormattedDate} - ${endOfWeek.shortFormattedDate}';
        break;
      case 'this_month':
        final now = DateTime.now();
        periodText = DateFormat('MMMM yyyy', 'tr_TR').format(now);
        break;
      case 'all_time':
        periodText = 'Tüm zamanlar';
        break;
      default:
        periodText = 'Bu hafta';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MoodColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MoodColors.accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            _getPeriodTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MoodColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            periodText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MoodColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(List<_MoodStat> data) {
    final total = data.fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return Container();

    final maxCount = data.fold<int>(0, (max, stat) {
      return stat.count > max ? stat.count : max;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MoodColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ruh Hali Dağılımı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MoodColors.textPrimary,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount == 0 ? 1 : maxCount.toDouble() + 1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => MoodColors.textPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x.toInt();
                      if (index < 0 || index >= data.length) {
                        return BarTooltipItem(
                          '',
                          TextStyle(color: Colors.white),
                        );
                      }
                      final mood = data[index];
                      return BarTooltipItem(
                        '${mood.name}\n${rod.toY.toInt()} kayıt',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: MoodColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          final mood = data[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final moodIndex = entry.key;
                  return BarChartGroupData(
                    x: moodIndex,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.count.toDouble(),
                        color: entry.value.color,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(List<_MoodStat> data) {
    final total = data.fold<int>(0, (sum, stat) => sum + stat.count);
    final mostFrequentCandidates = data.where((stat) => stat.count > 0).toList();
    final mostFrequent = mostFrequentCandidates.isEmpty
        ? null
        : mostFrequentCandidates
            .reduce((a, b) => a.count > b.count ? a : b);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Toplam Kayıt',
            value: total.toString(),
            icon: Icons.dashboard,
            color: MoodColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'En Sık Ruh Hali',
            value: mostFrequent?.emoji ?? '😐',
            subtitle: mostFrequent?.name ?? 'Yok',
            icon: Icons.emoji_emotions,
            color: mostFrequent != null
                ? mostFrequent.color
                : MoodColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MoodColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
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
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MoodColors.textPrimary,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MoodColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown(List<_MoodStat> data) {
    final total = data.fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return Container();
    final maxCount = data.fold<int>(0, (max, stat) {
      return stat.count > max ? stat.count : max;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MoodColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı Analiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MoodColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...data.where((entry) => entry.count > 0).map((entry) {
            final percentage = (entry.count / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: entry.color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: entry.color.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        entry.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: MoodColors.textPrimary,
                                  ),
                            ),
                            Text(
                              '%$percentage · ${entry.count} kayıt',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MoodColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: maxCount == 0 ? 0 : entry.count / maxCount,
                          backgroundColor: entry.color.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            entry.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsights(List<_MoodStat> data) {
    final insights = _generateInsights(data);
    
    if (insights.isEmpty) return Container();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MoodColors.accent.withOpacity(0.1),
            MoodColors.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MoodColors.accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: MoodColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'İçgörüler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MoodColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: MoodColors.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: MoodColors.textPrimary,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: MoodColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Analiz için yeterli veri yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: MoodColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ruh hali kayıtlarınızı analizsini görmek için daha fazla kayıt ekleyin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MoodColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<_MoodStat> _getAnalysisData(MoodProvider moodProvider) {
    List<MoodEntry> entries;
    
    switch (_selectedPeriod) {
      case 'this_week':
        entries = moodProvider.getThisWeekEntries();
        break;
      case 'this_month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        entries = moodProvider.entries.where((entry) {
          return entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                 entry.date.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();
        break;
      case 'all_time':
        entries = moodProvider.entries;
        break;
      default:
        entries = moodProvider.getThisWeekEntries();
    }

    final stats = <_MoodStat>[];
    final statsById = <String, _MoodStat>{};

    void addStat(_MoodStat stat) {
      stats.add(stat);
      statsById[stat.id] = stat;
    }

    for (final mood in Mood.values) {
      addStat(
        _MoodStat(
          id: 'builtin:${mood.value}',
          emoji: mood.emoji,
          name: mood.displayName,
          color: MoodColors.getColor(mood),
          isCustom: false,
        ),
      );
    }

    for (final custom in moodProvider.customMoods) {
      addStat(
        _MoodStat(
          id: 'custom:${custom.id}',
          emoji: custom.emoji,
          name: custom.displayName,
          color: Color(custom.colorValue),
          isCustom: true,
        ),
      );
    }

    for (final entry in entries) {
      if (entry.customMood != null) {
        final custom = entry.customMood!;
        final id = 'custom:${custom.id}';
        final stat = statsById[id] ??
            (() {
              final newStat = _MoodStat(
                id: id,
                emoji: custom.emoji,
                name: custom.displayName,
                color: Color(custom.colorValue),
                isCustom: true,
              );
              addStat(newStat);
              return newStat;
            })();
        stat.count += 1;
      } else {
        final id = 'builtin:${entry.mood.value}';
        final stat = statsById[id];
        if (stat != null) {
          stat.count += 1;
        }
      }
    }

    return stats;
  }

  List<String> _generateInsights(List<_MoodStat> data) {
    final insights = <String>[];
    final total = data.fold<int>(0, (sum, stat) => sum + stat.count);
    
    if (total == 0) return insights;

    // Most frequent mood
    final mostFrequent = data.reduce((a, b) => a.count > b.count ? a : b);
    if (mostFrequent.count > 0) {
      final percentage = (mostFrequent.count / total * 100).round();
      insights.add('Bu dönemde en çok ${mostFrequent.name.toLowerCase()} hissettiniz (%$percentage).');
    }

    // Positive vs negative moods
    final positiveMoods = [Mood.happy, Mood.excited, Mood.calm];
    final negativeMoods = [Mood.sad, Mood.angry, Mood.anxious];
    
    int countForMood(Mood mood) {
      final id = 'builtin:${mood.value}';
      for (final stat in data) {
        if (stat.id == id) {
          return stat.count;
        }
      }
      return 0;
    }

    final positiveCount = positiveMoods.fold(
      0,
      (sum, mood) => sum + countForMood(mood),
    );
    final negativeCount = negativeMoods.fold(
      0,
      (sum, mood) => sum + countForMood(mood),
    );
    
    if (positiveCount > negativeCount) {
      insights.add('Bu dönemde genellikle pozitif duygular yaşadınız. Harika!');
    } else if (negativeCount > positiveCount) {
      insights.add('Bu dönemde zorlu duygular yaşadınız. Kendinize daha fazla özen göstermeyi deneyin.');
    } else {
      insights.add('Bu dönemde duygusal dengenizi korudunuz.');
    }

    // Diversity of emotions
    final activeMoods = data.where((stat) => stat.count > 0).length;
    if (activeMoods >= 5) {
      insights.add('Geniş bir duygu yelpazesi yaşadınız, bu duygusal zenginliğin bir göstergesi.');
    }

    return insights;
  }

  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case 'this_week':
        return 'Bu Hafta';
      case 'this_month':
        return 'Bu Ay';
      case 'all_time':
        return 'Tüm Zamanlar';
      default:
        return 'Bu Hafta';
    }
  }

  void _showPeriodSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dönem Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Bu hafta'),
                value: 'this_week',
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: MoodColors.accent,
              ),
              RadioListTile<String>(
                title: const Text('Bu ay'),
                value: 'this_month',
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: MoodColors.accent,
              ),
              RadioListTile<String>(
                title: const Text('Tüm zamanlar'),
                value: 'all_time',
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: MoodColors.accent,
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
}
