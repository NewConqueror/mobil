import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mood_entry.dart';
import '../utils/mood_entry_display.dart';

class ExportService {
  static final ExportService _instance = ExportService._();
  
  ExportService._();
  
  static ExportService get instance => _instance;

  /// Tüm günlük kayıtlarını formatlanmış metin olarak döndürür
  String formatEntriesAsText(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 'Henüz kayıtlı günlük bulunmuyor.';
    }

    final buffer = StringBuffer();
    final dateFormatter = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR');
    final timeFormatter = DateFormat('HH:mm', 'tr_TR');

    // Başlık
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('          RUH HALİ GÜNLÜĞÜ');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Toplam kayıt sayısı: ${entries.length}');
    buffer.writeln('Dışa aktarım tarihi: ${dateFormatter.format(DateTime.now())}');
    buffer.writeln();
    buffer.writeln('───────────────────────────────────────────');
    buffer.writeln();

    // Tarihe göre sıralı kayıtlar (en yeniden eskiye)
    final sortedEntries = List<MoodEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      
      buffer.writeln('📅 ${dateFormatter.format(entry.date)}');
      buffer.writeln('${entry.emoji} Ruh Hali: ${entry.displayName}');
      
      if (entry.moodSetAt != null) {
        buffer.writeln('⏰ Saat: ${timeFormatter.format(entry.moodSetAt!)}');
      }
      
      buffer.writeln();
      
      if (entry.note.isNotEmpty) {
        buffer.writeln('📝 Not:');
        buffer.writeln(entry.note);
      } else {
        buffer.writeln('📝 Not: (boş)');
      }
      
      buffer.writeln();
      
      // Son kayıt değilse ayırıcı çizgi ekle
      if (i < sortedEntries.length - 1) {
        buffer.writeln('───────────────────────────────────────────');
        buffer.writeln();
      }
    }

    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('              GÜNLÜK SONU');
    buffer.writeln('═══════════════════════════════════════════');

    return buffer.toString();
  }

  /// Günlük kayıtlarını TXT dosyası olarak dışa aktar ve paylaş
  Future<ExportResult> exportAndShare(List<MoodEntry> entries) async {
    try {
      final content = formatEntriesAsText(entries);
      final file = await _saveToFile(content);
      
      // Share Plus ile paylaş
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Ruh Hali Günlüğüm',
        text: 'Ruh hali günlüğüm dışa aktarıldı.',
      );
      
      return ExportResult(
        success: true,
        filePath: file.path,
        message: 'Dışa aktarım başarılı!',
        shareResult: result,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Dışa aktarım hatası: $e',
      );
    }
  }

  /// Sadece dosyaya kaydet (paylaşmadan)
  Future<ExportResult> exportToFile(List<MoodEntry> entries) async {
    try {
      final content = formatEntriesAsText(entries);
      final file = await _saveToFile(content);
      
      return ExportResult(
        success: true,
        filePath: file.path,
        message: 'Dosya başarıyla kaydedildi: ${file.path}',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Dosya kaydetme hatası: $e',
      );
    }
  }

  /// İçeriği TXT dosyasına kaydet
  Future<File> _saveToFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'ruh_hali_gunlugu_$timestamp.txt';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(content, flush: true);
    
    return file;
  }
}

/// Export işleminin sonuç modeli
class ExportResult {
  final bool success;
  final String? filePath;
  final String message;
  final ShareResult? shareResult;

  ExportResult({
    required this.success,
    this.filePath,
    required this.message,
    this.shareResult,
  });
}
