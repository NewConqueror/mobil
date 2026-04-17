import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Returns a formatted date string like "15 Ocak 2024"
  String get formattedDate {
    return DateFormat('dd MMMM yyyy', 'tr_TR').format(this);
  }

  /// Returns a formatted date string like "15 Oca"
  String get shortFormattedDate {
    return DateFormat('dd MMM', 'tr_TR').format(this);
  }

  /// Returns time string like "14:30"
  String get formattedTime {
    return DateFormat('HH:mm').format(this);
  }

  /// Returns formatted date and time like "15 Ocak 2024, 14:30"
  String get formattedDateTime {
    return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(this);
  }

  /// Returns day name like "Pazartesi"
  String get dayName {
    return DateFormat('EEEE', 'tr_TR').format(this);
  }

  /// Returns short day name like "Pzt"
  String get shortDayName {
    return DateFormat('E', 'tr_TR').format(this);
  }

  /// Checks if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns the difference in days from today
  int get daysFromToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(year, month, day);
    return today.difference(thisDate).inDays;
  }

  /// Returns relative date string like "Bugün", "Dün", "2 gün önce"
  String get relativDateString {
    if (isToday) return 'Bugün';
    if (isYesterday) return 'Dün';
    
    final days = daysFromToday;
    if (days > 0) {
      return '$days gün önce';
    } else if (days < 0) {
      return '${-days} gün sonra';
    }
    return formattedDate;
  }

  /// Returns date only (without time)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns the start of the week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).dateOnly;
  }

  /// Returns the end of the week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).dateOnly;
  }
}
