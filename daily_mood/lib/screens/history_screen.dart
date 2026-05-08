import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mood_provider.dart';
import '../services/export_service.dart';
import '../models/mood_entry.dart';
import '../widgets/mood_entry_card.dart';
import '../utils/mood_colors.dart';
import '../utils/date_extensions.dart';
import 'add_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, this_week, this_month

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
          'Geçmiş Kayıtlar',
          style: TextStyle(
            color: MoodColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _exportEntries(context),
            icon: const Icon(
              Icons.file_download_outlined,
              color: MoodColors.textSecondary,
            ),
            tooltip: 'Dışa Aktar',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.filter_list,
              color: _selectedFilter == 'all' 
                  ? MoodColors.textSecondary 
                  : MoodColors.accent,
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

          final filteredEntries = _getFilteredEntries(moodProvider.entries);

          if (filteredEntries.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Search bar
              _buildSearchBar(),
              
              // Entries list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await moodProvider.loadEntries();
                  },
                  color: MoodColors.accent,
                  child: _buildEntriesList(filteredEntries, moodProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Notlarda ara...',
          hintStyle: TextStyle(
            color: MoodColors.textSecondary.withOpacity(0.7),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: MoodColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          color: MoodColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEntriesList(List<MoodEntry> entries, MoodProvider moodProvider) {
    final groupedEntries = _groupEntriesByDate(entries);
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateEntries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MoodColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      date.relativDateString,
                      style: const TextStyle(
                        color: MoodColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: MoodColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            
            // Entries for this date
            ...dateEntries.map((entry) => MoodEntryCard(
                  entry: entry,
                  showDate: false,
                  onTap: () => _navigateToEditEntry(entry),
                  onDelete: () => _confirmDeleteEntry(entry.id, moodProvider),
                )),
          ],
        );
      },
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
              Icons.history,
              size: 80,
              color: MoodColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'all' 
                  ? 'Henüz kayıt yok'
                  : 'Bu dönem için kayıt yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: MoodColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'all'
                  ? 'İlk ruh hali kaydınızı ekleyin'
                  : 'Seçilen dönem için kayıt bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MoodColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter != 'all') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'all';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MoodColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Tüm Kayıtları Göster'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<MoodEntry> _getFilteredEntries(List<MoodEntry> allEntries) {
    List<MoodEntry> filtered = allEntries;

    // Apply time filter
    switch (_selectedFilter) {
      case 'this_week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        filtered = allEntries.where((entry) {
          return entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 entry.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
        break;
      case 'this_month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        filtered = allEntries.where((entry) {
          return entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                 entry.date.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry.note.toLowerCase().contains(_searchQuery) ||
               entry.mood.displayName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  Map<DateTime, List<MoodEntry>> _groupEntriesByDate(List<MoodEntry> entries) {
    final grouped = <DateTime, List<MoodEntry>>{};
    
    for (final entry in entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }
    
    return grouped;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrele'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Tüm kayıtlar'),
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: MoodColors.accent,
              ),
              RadioListTile<String>(
                title: const Text('Bu hafta'),
                value: 'this_week',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: MoodColors.accent,
              ),
              RadioListTile<String>(
                title: const Text('Bu ay'),
                value: 'this_month',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
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

  void _navigateToEditEntry(MoodEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(existingEntry: entry),
      ),
    );
  }

  void _confirmDeleteEntry(String entryId, MoodProvider moodProvider) {
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
                moodProvider.deleteMoodEntry(entryId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kayıt silindi'),
                    backgroundColor: MoodColors.accent,
                    behavior: SnackBarBehavior.floating,
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

  Future<void> _exportEntries(BuildContext context) async {
    final moodProvider = context.read<MoodProvider>();
    final entries = moodProvider.entries;

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dışa aktarılacak kayıt bulunamadı.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: MoodColors.accent),
      ),
    );

    try {
      final result = await ExportService.instance.exportAndShare(entries);
      
      // Loading'i kapat
      if (mounted) Navigator.of(context).pop();

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${entries.length} kayıt dışa aktarıldı!'),
              backgroundColor: MoodColors.accent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
