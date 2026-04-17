import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class StatsWidget extends StatelessWidget {
  final bool isDialog;

  const StatsWidget({
    super.key,
    this.isDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (!isDialog && todoProvider.todoItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: isDialog ? 0 : 4,
          margin: isDialog ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'İstatistikler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                if (todoProvider.totalTodoItems > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: todoProvider.completionPercentage / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(todoProvider.completionPercentage),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${todoProvider.completionPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Stats grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Toplam Görev',
                        todoProvider.totalTodoItems.toString(),
                        Icons.task_alt,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Tamamlanan',
                        todoProvider.completedTodoItemsCount.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Bekleyen',
                        todoProvider.incompleteTodoItemsCount.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Önemli',
                        todoProvider.importantTodoItemsCount.toString(),
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                
                // Background service status
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: todoProvider.isBackgroundServiceRunning 
                      ? Colors.green.shade50 
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: todoProvider.isBackgroundServiceRunning 
                        ? Colors.green 
                        : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        todoProvider.isBackgroundServiceRunning 
                          ? Icons.notifications_active 
                          : Icons.notifications_off,
                        color: todoProvider.isBackgroundServiceRunning 
                          ? Colors.green 
                          : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          todoProvider.isBackgroundServiceRunning 
                            ? 'Bildirimler Aktif (08:00-23:00)' 
                            : 'Bildirimler Kapalı',
                          style: TextStyle(
                            color: todoProvider.isBackgroundServiceRunning 
                              ? Colors.green.shade700 
                              : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
