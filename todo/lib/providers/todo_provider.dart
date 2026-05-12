import 'package:flutter/foundation.dart';
import '../models/todo_item.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TodoProvider with ChangeNotifier {
  final List<TodoItem> _todoItems = [];
  final List<TodoItem> _notTodoItems = [];
  
  late StorageService _storageService;
  late NotificationService _notificationService;
  
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _backgroundServiceEnabled = false;

  List<TodoItem> get todoItems => List.unmodifiable(_todoItems);
  List<TodoItem> get notTodoItems => List.unmodifiable(_notTodoItems);
  List<TodoItem> get completedTodoItems => _todoItems.where((item) => item.isCompleted).toList();
  List<TodoItem> get incompleteTodoItems => _todoItems.where((item) => !item.isCompleted).toList();
  
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isBackgroundServiceRunning => _backgroundServiceEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _storageService = await StorageService.getInstance();
      _notificationService = NotificationService();
      await _notificationService.initialize();
        _backgroundServiceEnabled =
          await _notificationService.getBackgroundServiceEnabled();
      
      // Load existing items
      await _loadTodoItems();
      await _loadNotTodoItems();
      
      // Initialize with default "not-todo" items if first launch
      if (await _storageService.isFirstLaunch()) {
        await _initializeDefaultNotTodoItems();
        await _storageService.setFirstLaunch(false);
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TodoProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTodoItems() async {
    try {
      final List<Map<String, dynamic>> jsonList = await _storageService.getTodoItems();
      _todoItems.clear();
      _todoItems.addAll(jsonList.map((json) => TodoItem.fromJson(json)));
    } catch (e) {
      print('Error loading todo items: $e');
    }
  }

  Future<void> _loadNotTodoItems() async {
    try {
      final List<Map<String, dynamic>> jsonList = await _storageService.getNotTodoItems();
      _notTodoItems.clear();
      _notTodoItems.addAll(jsonList.map((json) => TodoItem.fromJson(json)));
    } catch (e) {
      print('Error loading not-todo items: $e');
    }
  }

  Future<void> _saveTodoItems() async {
    try {
      final List<Map<String, dynamic>> jsonList = _todoItems.map((item) => item.toJson()).toList();
      await _storageService.saveTodoItems(jsonList);
    } catch (e) {
      print('Error saving todo items: $e');
    }
  }

  Future<void> _saveNotTodoItems() async {
    try {
      final List<Map<String, dynamic>> jsonList = _notTodoItems.map((item) => item.toJson()).toList();
      await _storageService.saveNotTodoItems(jsonList);
    } catch (e) {
      print('Error saving not-todo items: $e');
    }
  }

  Future<void> _initializeDefaultNotTodoItems() async {
    final defaultNotTodoItems = [
      TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Sosyal Medyada Anlamsız Vakit Geçirmek',
        description: 'Instagram, TikTok, Facebook\'ta saatlerce scrolling yapmak',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Dizi/Film Maratonu Yapmak',
        description: 'Tüm gün dizi izleyip üretken işleri ertelemek',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Oyun Oynamakta Kendini Kaybetmek',
        description: 'Saatlerce oyun oynayıp zamanı boşa harcamak',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Gereksiz Online Alışveriş Yapmak',
        description: 'İhtiyacı olmayan şeyleri impulse buying ile almak',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        title: 'Gosip ve Dedikodu ile Vakit Geçirmek',
        description: 'Başkalarının özel hayatları hakkında konuşmak',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
        title: 'Aşırı Yemek Yemek (Junk Food)',
        description: 'Stres yemesi yapmak ve sağlıksız beslenme',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 6).toString(),
        title: 'Procrastination - İşleri Sürekli Ertelemek',
        description: 'Önemli görevleri sürekli yarına bırakmak',
        createdAt: DateTime.now(),
      ),
      TodoItem(
        id: (DateTime.now().millisecondsSinceEpoch + 7).toString(),
        title: 'Olumsuz Düşünce Spirali',
        description: 'Kendini karamsar düşüncelerle meşgul etmek',
        createdAt: DateTime.now(),
      ),
    ];

    _notTodoItems.addAll(defaultNotTodoItems);
    await _saveNotTodoItems();
    notifyListeners();
  }

  // Todo Item Methods
  Future<void> addTodoItem(String title, String description, {bool isImportant = false}) async {
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      isImportant: isImportant,
    );

    _todoItems.add(newItem);
    await _saveTodoItems();
    notifyListeners();
  }

  Future<void> updateTodoItem(TodoItem updatedItem) async {
    final index = _todoItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _todoItems[index] = updatedItem;
      await _saveTodoItems();
      notifyListeners();
    }
  }

  Future<void> toggleTodoComplete(String id) async {
    final index = _todoItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _todoItems[index];
      final updatedItem = item.copyWith(
        isCompleted: !item.isCompleted,
        completedAt: !item.isCompleted ? DateTime.now() : null,
      );
      _todoItems[index] = updatedItem;
      await _saveTodoItems();
      notifyListeners();
    }
  }

  Future<void> deleteTodoItem(String id) async {
    _todoItems.removeWhere((item) => item.id == id);
    await _saveTodoItems();
    notifyListeners();
  }

  // Not-Todo Item Methods
  Future<void> addNotTodoItem(String title, String description) async {
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _notTodoItems.add(newItem);
    await _saveNotTodoItems();
    notifyListeners();
  }

  Future<void> updateNotTodoItem(TodoItem updatedItem) async {
    final index = _notTodoItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _notTodoItems[index] = updatedItem;
      await _saveNotTodoItems();
      notifyListeners();
    }
  }

  Future<void> deleteNotTodoItem(String id) async {
    _notTodoItems.removeWhere((item) => item.id == id);
    await _saveNotTodoItems();
    notifyListeners();
  }

  // Notification Methods
  Future<void> toggleBackgroundService() async {
    await _notificationService.toggleBackgroundService();
    _backgroundServiceEnabled =
        await _notificationService.getBackgroundServiceEnabled();
    notifyListeners();
  }

  Future<void> testNotification() async {
    await _notificationService.testNotification();
  }

  Future<void> refreshBackgroundServiceStatus() async {
    _backgroundServiceEnabled =
        await _notificationService.getBackgroundServiceEnabled();
    notifyListeners();
  }

  // Statistics
  int get totalTodoItems => _todoItems.length;
  int get completedTodoItemsCount => _todoItems.where((item) => item.isCompleted).length;
  int get incompleteTodoItemsCount => _todoItems.where((item) => !item.isCompleted).length;
  int get importantTodoItemsCount => _todoItems.where((item) => item.isImportant && !item.isCompleted).length;
  
  double get completionPercentage {
    if (_todoItems.isEmpty) return 0.0;
    return (completedTodoItemsCount / totalTodoItems) * 100;
  }
}
