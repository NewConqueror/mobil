import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood.dart';
import '../models/mood_entry.dart';
import '../services/mood_provider.dart';
import '../widgets/mood_selector.dart';
import '../utils/mood_colors.dart';
import '../utils/date_extensions.dart';

class AddEntryScreen extends StatefulWidget {
  final MoodEntry? existingEntry;

  const AddEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _noteController;
  Mood? _selectedMood;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _canChangeMood = true;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();

    if (widget.existingEntry != null) {
      _selectedMood = widget.existingEntry!.mood;
      _noteController.text = widget.existingEntry!.note;
      _selectedDate = widget.existingEntry!.date;
      _canChangeMood = widget.existingEntry!.canChangeMoodToday;
    } else {
      // Yeni kayıt için bugünkü mood değiştirilip değiştirilemeyeceğini kontrol et
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final moodProvider = context.read<MoodProvider>();
        setState(() {
          _canChangeMood = moodProvider.canChangeMood(_selectedDate);
        });
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingEntry != null;
  bool get _canSave =>
      _selectedMood != null || _noteController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: MoodColors.textPrimary),
        ),
        title: Text(
          _isEditing ? 'Kaydı Düzenle' : 'Yeni Kayıt',
          style: const TextStyle(
            color: MoodColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selection
                  _buildDateSection(),

                  const SizedBox(height: 24),

                  // Mood selection
                  MoodSelector(
                    selectedMood: _selectedMood,
                    canChangeMood: _canChangeMood,
                    onMoodSelected: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Note input
                  _buildNoteSection(),

                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Tarih',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: MoodColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: MoodColors.textSecondary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: MoodColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate.formattedDate,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: MoodColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedDate.isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: MoodColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Bugün',
                        style: TextStyle(
                          color: MoodColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: MoodColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Notlarınız (İsteğe bağlı)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: MoodColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: null,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Bugün nasıl hissettiğinizi açıklayın...',
              hintStyle: TextStyle(
                color: MoodColors.textSecondary.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: MoodColors.textSecondary.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: MoodColors.textSecondary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MoodColors.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(color: MoodColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: FloatingActionButton.extended(
        onPressed: _canSave && !_isLoading ? _saveEntry : null,
        backgroundColor: _canSave
            ? MoodColors.accent
            : MoodColors.textSecondary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(_isEditing ? Icons.save : Icons.add),
        label: Text(
          _isLoading
              ? 'Kaydediliyor...'
              : _isEditing
              ? 'Güncelle'
              : 'Kaydet',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MoodColors.accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: MoodColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_canSave && _noteController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final moodProvider = context.read<MoodProvider>();

      if (_isEditing) {
        final updatedEntry = widget.existingEntry!.copyWith(
          mood: _selectedMood,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );
        await moodProvider.updateMoodEntry(updatedEntry);
      } else {
        // Yeni kayıt veya mevcut kaydın güncellenmesi
        if (_selectedMood != null) {
          // Mood ve not ekleme/güncelleme
          await moodProvider.addMoodEntry(
            mood: _selectedMood!,
            note: _noteController.text.trim(),
            date: _selectedDate,
          );
        } else {
          // Sadece not güncelleme
          await moodProvider.updateNote(
            note: _noteController.text.trim(),
            date: _selectedDate,
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Kayıt güncellendi' : 'Kayıt eklendi'),
            backgroundColor: MoodColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kaydı Sil'),
          content: const Text(
            'Bu ruh hali kaydını silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: _deleteEntry,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntry() async {
    Navigator.of(context).pop(); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<MoodProvider>().deleteMoodEntry(
        widget.existingEntry!.id,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt silindi'),
            backgroundColor: MoodColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
