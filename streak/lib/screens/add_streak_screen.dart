import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/streak_provider.dart';
import '../utils/streak_theme.dart';

class AddStreakScreen extends StatefulWidget {
  const AddStreakScreen({super.key});

  @override
  State<AddStreakScreen> createState() => _AddStreakScreenState();
}

class _AddStreakScreenState extends State<AddStreakScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Önceden tanımlı streak örnekleri
  final List<Map<String, String>> _presetStreaks = [
    {
      'title': 'Spor Yapmak',
      'description': 'Her gün en az 30 dakika spor yapmak',
      'icon': '🏃‍♂️',
    },
    {
      'title': 'Kitap Okumak',
      'description': 'Her gün en az 30 sayfa kitap okumak',
      'icon': '📚',
    },
    {
      'title': 'Su İçmek',
      'description': 'Günde en az 2 litre su içmek',
      'icon': '💧',
    },
    {
      'title': 'Meditasyon',
      'description': 'Günlük 10 dakika meditasyon yapmak',
      'icon': '🧘‍♂️',
    },
    {
      'title': 'Erken Kalkmak',
      'description': 'Her gün sabah 7\'de kalkmak',
      'icon': '🌅',
    },
    {
      'title': 'Sigara İçmemek',
      'description': 'Sigarayı bırakma hedefim',
      'icon': '🚭',
    },
    {
      'title': 'Yürüyüş',
      'description': 'Her gün en az 10.000 adım atmak',
      'icon': '🚶‍♂️',
    },
    {
      'title': 'Günlük Yazı',
      'description': 'Her gün günlük yazmak',
      'icon': '📝',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreakColors.background,
      appBar: AppBar(
        title: const Text(
          'Yeni Streak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: StreakColors.textOnPrimary,
          ),
        ),
        backgroundColor: StreakColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: StreakColors.textOnPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(StreakSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: StreakSizes.paddingXl),
            _buildPresetStreaks(),
            const SizedBox(height: StreakSizes.paddingXl),
            _buildCustomForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(StreakSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: StreakColors.primaryGradient,
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(StreakSizes.paddingMd),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
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
                      'Yeni Streak Oluştur',
                      style: StreakTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: StreakSizes.paddingSm),
                    Text(
                      'Hedefini belirle ve her gün takip et',
                      style: StreakTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetStreaks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hazır Şablonlar',
          style: StreakTextStyles.heading3,
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        Text(
          'Popüler hedeflerden birini seç veya kendi hedefini oluştur',
          style: StreakTextStyles.bodyMedium,
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: StreakSizes.paddingMd,
            mainAxisSpacing: StreakSizes.paddingMd,
          ),
          itemCount: _presetStreaks.length,
          itemBuilder: (context, index) {
            final preset = _presetStreaks[index];
            return _buildPresetCard(preset);
          },
        ),
      ],
    );
  }

  Widget _buildPresetCard(Map<String, String> preset) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
      ),
      child: InkWell(
        onTap: () => _selectPreset(preset),
        borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(StreakSizes.paddingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset['icon']!,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: StreakSizes.paddingSm),
              Text(
                preset['title']!,
                style: StreakTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özel Streak',
          style: StreakTextStyles.heading3,
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        Text(
          'Kendi hedefini oluştur',
          style: StreakTextStyles.bodyMedium,
        ),
        const SizedBox(height: StreakSizes.paddingMd),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Streak Başlığı',
                  hintText: 'örn: Spor yapmak',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
                    borderSide: const BorderSide(color: StreakColors.primary),
                  ),
                  prefixIcon: const Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  if (value.trim().length < 3) {
                    return 'Başlık en az 3 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: StreakSizes.paddingMd),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Hedefin hakkında detay ver',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
                    borderSide: const BorderSide(color: StreakColors.primary),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  if (value.trim().length < 10) {
                    return 'Açıklama en az 10 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: StreakSizes.paddingXl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createStreak,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StreakColors.accent,
                    foregroundColor: StreakColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Streak Oluştur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectPreset(Map<String, String> preset) {
    setState(() {
      _titleController.text = preset['title']!;
      _descriptionController.text = preset['description']!;
    });
    
    // Scroll to form
    Future.delayed(const Duration(milliseconds: 200), () {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _createStreak() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<StreakProvider>(context, listen: false);
      final success = await provider.addStreak(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Streak başarıyla oluşturuldu!'),
              backgroundColor: StreakColors.streakSuccess,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Streak oluşturulamadı. Tekrar deneyin.'),
              backgroundColor: StreakColors.streakDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: StreakColors.streakDanger,
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
