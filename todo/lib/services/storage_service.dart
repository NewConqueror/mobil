import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._internal();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._internal();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Todo items storage
  Future<void> saveTodoItems(List<Map<String, dynamic>> todoItems) async {
    final String jsonString = json.encode(todoItems);
    await _prefs.setString('todo_items', jsonString);
  }

  Future<List<Map<String, dynamic>>> getTodoItems() async {
    final String? jsonString = _prefs.getString('todo_items');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Not-todo items storage
  Future<void> saveNotTodoItems(List<Map<String, dynamic>> notTodoItems) async {
    final String jsonString = json.encode(notTodoItems);
    await _prefs.setString('not_todo_items', jsonString);
  }

  Future<List<Map<String, dynamic>>> getNotTodoItems() async {
    final String? jsonString = _prefs.getString('not_todo_items');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Background service settings
  Future<void> setBackgroundServiceEnabled(bool enabled) async {
    await _prefs.setBool('background_service_enabled', enabled);
  }

  Future<bool> getBackgroundServiceEnabled() async {
    return _prefs.getBool('background_service_enabled') ?? false;
  }

  // Notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  // First launch detection
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool('is_first_launch', isFirst);
  }

  Future<bool> isFirstLaunch() async {
    return _prefs.getBool('is_first_launch') ?? true;
  }
}
