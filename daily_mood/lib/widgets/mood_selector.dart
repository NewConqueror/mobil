import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood.dart';
import '../models/custom_mood.dart';
import '../services/mood_provider.dart';
import '../utils/mood_colors.dart';

// Unified mood item that can represent either a built-in Mood or a CustomMood
class MoodItem {
  final String id;
  final String emoji;
  final String displayName;
  final Color color;
  final bool isCustom;
  final Mood? builtInMood;
  final CustomMood? customMood;

  MoodItem({
    required this.id,
    required this.emoji,
    required this.displayName,
    required this.color,
    required this.isCustom,
    this.builtInMood,
    this.customMood,
  });

  factory MoodItem.fromMood(Mood mood) {
    return MoodItem(
      id: mood.value,
      emoji: mood.emoji,
      displayName: mood.displayName,
      color: MoodColors.getColor(mood),
      isCustom: false,
      builtInMood: mood,
    );
  }

  factory MoodItem.fromCustomMood(CustomMood mood) {
    return MoodItem(
      id: mood.id,
      emoji: mood.emoji,
      displayName: mood.displayName,
      color: Color(mood.colorValue),
      isCustom: true,
      customMood: mood,
    );
  }
}

class MoodSelector extends StatefulWidget {
  final Mood? selectedMood;
  final CustomMood? selectedCustomMood;
  final Function(Mood) onMoodSelected;
  final Function(CustomMood)? onCustomMoodSelected;
  final double size;
  final bool canChangeMood;
  final bool showAddButton;
  final bool showEditButton;

  const MoodSelector({
    super.key,
    this.selectedMood,
    this.selectedCustomMood,
    required this.onMoodSelected,
    this.onCustomMoodSelected,
    this.size = 60.0,
    this.canChangeMood = true,
    this.showAddButton = true,
    this.showEditButton = true,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectMood(Mood mood) {
    if (!widget.canChangeMood) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bugün ruh halinizi zaten seçtiniz. Sadece notunuzu güncelleyebilirsiniz.',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onMoodSelected(mood);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _selectCustomMood(CustomMood mood) {
    if (!widget.canChangeMood) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bugün ruh halinizi zaten seçtiniz. Sadece notunuzu güncelleyebilirsiniz.',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onCustomMoodSelected?.call(mood);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _showAddMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditMoodDialog(),
    );
  }

  void _showEditMoodDialog(BuildContext context, CustomMood mood) {
    showDialog(
      context: context,
      builder: (context) => AddEditMoodDialog(existingMood: mood),
    );
  }

  void _confirmDeleteMood(BuildContext context, CustomMood mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruh Halini Sil'),
        content: Text(
          '"${mood.displayName}" ruh halini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<MoodProvider>().deleteCustomMood(mood.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final customMoods = moodProvider.customMoods;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.canChangeMood
                          ? 'Bugün nasıl hissediyorsun?'
                          : 'Bugünkü ruh haliniz: ${widget.selectedMood?.displayName ?? "Seçilmedi"}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MoodColors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.showEditButton && customMoods.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode = !_isEditMode;
                        });
                      },
                      icon: Icon(
                        _isEditMode ? Icons.done : Icons.edit,
                        color: MoodColors.accent,
                        size: 20,
                      ),
                      tooltip: _isEditMode
                          ? 'Düzenlemeyi Bitir'
                          : 'Ruh Hallerini Düzenle',
                    ),
                ],
              ),
              if (!widget.canChangeMood) ...[
                const SizedBox(height: 8),
                Text(
                  'Sadece notunuzu güncelleyebilirsiniz',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Built-in moods
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...Mood.values.map(
                    (mood) => _buildMoodItem(
                      mood: mood,
                      isSelected: widget.selectedMood == mood,
                      isEnabled:
                          widget.canChangeMood || widget.selectedMood == mood,
                    ),
                  ),

                  // Custom moods
                  ...customMoods.map(
                    (customMood) => _buildCustomMoodItem(
                      mood: customMood,
                      isSelected:
                          widget.selectedCustomMood?.id == customMood.id,
                      isEnabled:
                          widget.canChangeMood ||
                          widget.selectedCustomMood?.id == customMood.id,
                    ),
                  ),

                  // Add button
                  if (widget.showAddButton) _buildAddMoodButton(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodItem({
    required Mood mood,
    required bool isSelected,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? () => _selectMood(mood) : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale =
              isSelected &&
                  _animationController.status == AnimationStatus.forward
              ? _scaleAnimation.value
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.3,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: isSelected
                      ? MoodColors.getColor(mood)
                      : MoodColors.getSecondaryColor(mood),
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  border: Border.all(
                    color: isSelected
                        ? MoodColors.getPrimaryColor(mood)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: MoodColors.getColor(mood).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mood.emoji,
                      style: TextStyle(fontSize: widget.size * 0.4),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mood.displayName,
                      style: TextStyle(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.w500,
                        color: MoodColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomMoodItem({
    required CustomMood mood,
    required bool isSelected,
    required bool isEnabled,
  }) {
    final color = Color(mood.colorValue);

    return GestureDetector(
      onTap: isEnabled && !_isEditMode ? () => _selectCustomMood(mood) : null,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale =
                  isSelected &&
                      _animationController.status == AnimationStatus.forward
                  ? _scaleAnimation.value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: isEnabled ? 1.0 : 0.3,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      border: Border.all(
                        color: isSelected
                            ? color.withOpacity(0.7)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(fontSize: widget.size * 0.4),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            mood.displayName,
                            style: TextStyle(
                              fontSize: widget.size * 0.13,
                              fontWeight: FontWeight.w500,
                              color: MoodColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Edit/Delete buttons in edit mode
          if (_isEditMode)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(widget.size / 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditMoodDialog(context, mood),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: widget.size * 0.25,
                      ),
                    ),
                    SizedBox(width: widget.size * 0.1),
                    GestureDetector(
                      onTap: () => _confirmDeleteMood(context, mood),
                      child: Icon(
                        Icons.delete,
                        color: Colors.red.shade300,
                        size: widget.size * 0.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMoodButton() {
    return GestureDetector(
      onTap: () => _showAddMoodDialog(context),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: MoodColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.size / 2),
          border: Border.all(
            color: MoodColors.accent.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: MoodColors.accent, size: widget.size * 0.35),
            Text(
              'Ekle',
              style: TextStyle(
                fontSize: widget.size * 0.15,
                fontWeight: FontWeight.w500,
                color: MoodColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Mood Dialog
class AddEditMoodDialog extends StatefulWidget {
  final CustomMood? existingMood;

  const AddEditMoodDialog({super.key, this.existingMood});

  @override
  State<AddEditMoodDialog> createState() => _AddEditMoodDialogState();
}

class _AddEditMoodDialogState extends State<AddEditMoodDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  Color _selectedColor = const Color(0xFFFFE082);

  bool get _isEditing => widget.existingMood != null;

  // Preset colors for mood selection
  static const List<Color> _presetColors = [
    Color(0xFFFFE082), // Sarı
    Color(0xFF90CAF9), // Mavi
    Color(0xFFEF9A9A), // Kırmızı
    Color(0xFFA5D6A7), // Yeşil
    Color(0xFFCE93D8), // Mor
    Color(0xFFFFAB91), // Turuncu
    Color(0xFFF8BBD9), // Pembe
    Color(0xFF80DEEA), // Cyan
    Color(0xFFBCAAA4), // Kahverengi
    Color(0xFFB0BEC5), // Gri-mavi
  ];

  // Common emojis for moods
  static const List<String> _commonEmojis = [
    '😊',
    '😢',
    '😠',
    '😌',
    '😴',
    '🤩',
    '😰',
    '😐',
    '🥰',
    '😎',
    '🤔',
    '😅',
    '🥺',
    '😤',
    '🤗',
    '😇',
    '🙃',
    '😔',
    '😩',
    '🤯',
    '😳',
    '🥳',
    '😋',
    '🤪',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingMood?.displayName ?? '',
    );
    _emojiController = TextEditingController(
      text: widget.existingMood?.emoji ?? '😊',
    );
    if (widget.existingMood != null) {
      _selectedColor = Color(widget.existingMood!.colorValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _emojiController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid) return;

    final moodProvider = context.read<MoodProvider>();

    final mood = CustomMood(
      id:
          widget.existingMood?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      emoji: _emojiController.text.trim(),
      displayName: _nameController.text.trim(),
      colorValue: _selectedColor.value,
    );

    try {
      if (_isEditing) {
        await moodProvider.updateCustomMood(mood);
      } else {
        await moodProvider.addCustomMood(mood);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Ruh hali güncellendi' : 'Yeni ruh hali eklendi',
            ),
            backgroundColor: MoodColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Ruh Halini Düzenle' : 'Yeni Ruh Hali Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ruh Hali Adı',
                hintText: 'Örn: Huzurlu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Emoji field
            Text(
              'Emoji Seç',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _commonEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _commonEmojis[index];
                  final isSelected = _emojiController.text == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _emojiController.text = emoji;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MoodColors.accent.withOpacity(0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: MoodColors.accent, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color selection
            Text(
              'Renk Seç',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black54 : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.black54,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preview
            Text(
              'Önizleme',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _selectedColor.withOpacity(0.7),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _emojiController.text.isEmpty
                          ? '😊'
                          : _emojiController.text,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Ad'
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: MoodColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isValid ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: MoodColors.accent,
            foregroundColor: Colors.white,
          ),
          child: Text(_isEditing ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }
}

// Compact mood selector for smaller spaces
class CompactMoodSelector extends StatelessWidget {
  final Mood? selectedMood;
  final Function(Mood) onMoodSelected;
  final double size;

  const CompactMoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Mood.values.length,
        itemBuilder: (context, index) {
          final mood = Mood.values[index];
          final isSelected = selectedMood == mood;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isSelected
                      ? MoodColors.getColor(mood)
                      : MoodColors.getSecondaryColor(mood),
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(
                    color: isSelected
                        ? MoodColors.getPrimaryColor(mood)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    mood.emoji,
                    style: TextStyle(fontSize: size * 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
