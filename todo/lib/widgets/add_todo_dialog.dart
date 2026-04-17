import 'package:flutter/material.dart';

class AddTodoDialog extends StatefulWidget {
  final Function(String title, String description, bool isImportant)? onAddTodo;
  final Function(String title, String description)? onAddNotTodo;
  final String? initialTitle;
  final String? initialDescription;
  final bool? initialIsImportant;
  final bool isEditing;
  final bool isNotTodoMode;

  const AddTodoDialog({
    super.key,
    this.onAddTodo,
    this.onAddNotTodo,
    this.initialTitle,
    this.initialDescription,
    this.initialIsImportant,
    this.isEditing = false,
    this.isNotTodoMode = false,
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isImportant = false;
  bool _isNotTodoMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _isImportant = widget.initialIsImportant ?? false;
    _isNotTodoMode = widget.isNotTodoMode;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing 
          ? (_isNotTodoMode ? 'Yapılmayacak Düzenle' : 'Görev Düzenle')
          : 'Yeni Ekle',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selection (only for new items)
            if (!widget.isEditing) ...[
              const Text(
                'Tür Seçin:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isNotTodoMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: !_isNotTodoMode ? Colors.blue.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: !_isNotTodoMode ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_box,
                              color: !_isNotTodoMode ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yapılacak',
                              style: TextStyle(
                                color: !_isNotTodoMode ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isNotTodoMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _isNotTodoMode ? Colors.red.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _isNotTodoMode ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              color: _isNotTodoMode ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yapılmayacak',
                              style: TextStyle(
                                color: _isNotTodoMode ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            // Title field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: _isNotTodoMode ? 'Yapılmayacak Başlık' : 'Görev Başlığı',
                hintText: _isNotTodoMode 
                  ? 'Örn: Sosyal medyada vakit geçirmek'
                  : 'Örn: Projeyi tamamla',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_isNotTodoMode ? Icons.block : Icons.task),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                hintText: _isNotTodoMode 
                  ? 'Bu davranışın neden yapılmaması gerektiğini açıklayın'
                  : 'Görevin detaylarını açıklayın',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            
            // Important toggle (only for todos)
            if (!_isNotTodoMode) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Önemli Görev'),
                subtitle: const Text('Bu görev öncelikli olarak işaretlenecek'),
                value: _isImportant,
                onChanged: (value) => setState(() => _isImportant = value),
                secondary: Icon(
                  _isImportant ? Icons.star : Icons.star_border,
                  color: _isImportant ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.trim().isEmpty 
            ? null 
            : () {
                Navigator.pop(context);
                if (_isNotTodoMode) {
                  widget.onAddNotTodo?.call(
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                  );
                } else {
                  widget.onAddTodo?.call(
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                    _isImportant,
                  );
                }
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isNotTodoMode ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isEditing ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }
}
