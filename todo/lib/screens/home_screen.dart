import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/stats_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.check_box), text: 'Yapılacaklar'),
            Tab(icon: Icon(Icons.block), text: 'Yapılmayacaklar'),
          ],
        ),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return IconButton(
                icon: Icon(
                  todoProvider.isBackgroundServiceRunning 
                    ? Icons.notifications_active 
                    : Icons.notifications_off,
                  color: todoProvider.isBackgroundServiceRunning 
                    ? Colors.green 
                    : Colors.white70,
                ),
                onPressed: () => todoProvider.toggleBackgroundService(),
                tooltip: todoProvider.isBackgroundServiceRunning 
                  ? 'Bildirimleri Kapat' 
                  : 'Bildirimleri Aç',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStatsDialog(),
            tooltip: 'İstatistikler',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodoList(todoProvider),
              _buildNotTodoList(todoProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoList(TodoProvider todoProvider) {
    final incompleteTodos = todoProvider.incompleteTodoItems;
    final completedTodos = todoProvider.completedTodoItems;

    if (todoProvider.todoItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz görev eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni bir görev eklemek için + butonuna bas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats widget
        const StatsWidget(),
        const SizedBox(height: 16),
        
        // Incomplete todos
        if (incompleteTodos.isNotEmpty) ...[
          _buildSectionHeader('Yapılacaklar', incompleteTodos.length, Colors.orange),
          ...incompleteTodos.map((todo) => TodoItemWidget(
            todo: todo,
            onTap: () => todoProvider.toggleTodoComplete(todo.id),
            onEdit: () => _showEditTodoDialog(todo),
            onDelete: () => _showDeleteConfirmation(todo, true),
          )),
          const SizedBox(height: 16),
        ],
        
        // Completed todos
        if (completedTodos.isNotEmpty) ...[
          _buildSectionHeader('Tamamlananlar', completedTodos.length, Colors.green),
          ...completedTodos.map((todo) => TodoItemWidget(
            todo: todo,
            onTap: () => todoProvider.toggleTodoComplete(todo.id),
            onEdit: () => _showEditTodoDialog(todo),
            onDelete: () => _showDeleteConfirmation(todo, true),
          )),
        ],
      ],
    );
  }

  Widget _buildNotTodoList(TodoProvider todoProvider) {
    final notTodos = todoProvider.notTodoItems;

    if (notTodos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Yapılmayacaklar listesi boş',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Yapılmayacaklar', notTodos.length, Colors.red),
        ...notTodos.map((notTodo) => TodoItemWidget(
          todo: notTodo,
          isNotTodo: true,
          onEdit: () => _showEditNotTodoDialog(notTodo),
          onDelete: () => _showDeleteConfirmation(notTodo, false),
        )),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        onAddTodo: (title, description, isImportant) {
          context.read<TodoProvider>().addTodoItem(title, description, isImportant: isImportant);
        },
        onAddNotTodo: (title, description) {
          context.read<TodoProvider>().addNotTodoItem(title, description);
        },
      ),
    );
  }

  void _showEditTodoDialog(todo) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        initialTitle: todo.title,
        initialDescription: todo.description,
        initialIsImportant: todo.isImportant,
        isEditing: true,
        onAddTodo: (title, description, isImportant) {
          final updatedTodo = todo.copyWith(
            title: title,
            description: description,
            isImportant: isImportant,
          );
          context.read<TodoProvider>().updateTodoItem(updatedTodo);
        },
      ),
    );
  }

  void _showEditNotTodoDialog(notTodo) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        initialTitle: notTodo.title,
        initialDescription: notTodo.description,
        isEditing: true,
        isNotTodoMode: true,
        onAddNotTodo: (title, description) {
          final updatedNotTodo = notTodo.copyWith(
            title: title,
            description: description,
          );
          context.read<TodoProvider>().updateNotTodoItem(updatedNotTodo);
        },
      ),
    );
  }

  void _showDeleteConfirmation(item, bool isTodo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isTodo ? 'Görev' : 'Öğe'}i Sil'),
        content: Text('\"${item.title}\" ${isTodo ? 'görevini' : 'öğesini'} silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isTodo) {
                context.read<TodoProvider>().deleteTodoItem(item.id);
              } else {
                context.read<TodoProvider>().deleteNotTodoItem(item.id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isTodo ? 'Görev' : 'Öğe'} silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İstatistikler'),
        content: const StatsWidget(isDialog: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  todoProvider.testNotification();
                },
                child: const Text('Test Bildirimi'),
              );
            },
          ),
        ],
      ),
    );
  }
}
