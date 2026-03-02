// Flutter Task Reminder App - Local State Only (No Database)

import 'package:flutter/material.dart';
import 'task_models.dart';

void main() {
  runApp(const TaskReminderApp());
}

class TaskReminderApp extends StatelessWidget {
  const TaskReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // In-memory list of tasks (this will reset when app restarts)
  List<Task> _allTasks = [];
  
  // Filters
  TaskCategory? _selectedCategory;
  Priority? _selectedPriority;
  bool _showCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    _loadSampleData(); // Load some sample tasks
  }

  // Load sample tasks for demonstration
  void _loadSampleData() {
    _allTasks = [
      Task(
        id: '1',
        title: 'Buy groceries',
        description: 'Milk, eggs, bread, fruits',
        category: TaskCategory.shopping,
        priority: Priority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Task(
        id: '2',
        title: 'Finish project report',
        description: 'Complete the quarterly analysis',
        category: TaskCategory.work,
        priority: Priority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Task(
        id: '3',
        title: 'Morning jog',
        description: '5km run in the park',
        category: TaskCategory.health,
        priority: Priority.low,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Task(
        id: '4',
        title: 'Call dentist',
        description: 'Schedule annual checkup',
        category: TaskCategory.personal,
        priority: Priority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Get filtered tasks based on current filters
  List<Task> get _filteredTasks {
    List<Task> filtered = List.from(_allTasks);

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((task) => task.category == _selectedCategory).toList();
    }

    // Filter by priority
    if (_selectedPriority != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    // Filter by completion status
    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => !task.isDone).toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // Add a new task
  void _addTask(Task task) {
    setState(() {
      _allTasks.add(task);
    });
  }

  // Update an existing task
  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _allTasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
      }
    });
  }

  // Delete a task
  void _deleteTask(String taskId) {
    setState(() {
      _allTasks.removeWhere((task) => task.id == taskId);
    });
  }

  // Toggle task completion
  void _toggleTaskCompletion(Task task) {
    final updatedTask = task.copyWith(
      isDone: !task.isDone,
      completedAt: !task.isDone ? DateTime.now() : null,
    );
    _updateTask(updatedTask);
  }

  // Update task priority
  void _updateTaskPriority(Task task, Priority newPriority) {
    final updatedTask = task.copyWith(priority: newPriority);
    _updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 2,
        actions: [
          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'show_completed') {
                  _showCompletedTasks = !_showCompletedTasks;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'show_completed',
                child: Row(
                  children: [
                    Icon(
                      _showCompletedTasks 
                        ? Icons.check_box 
                        : Icons.check_box_outline_blank
                    ),
                    const SizedBox(width: 8),
                    const Text('Show Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Category filters
                ...TaskCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category.label),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Priority filters
                ...Priority.values.map((priority) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(priority.label),
                      selected: _selectedPriority == priority,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPriority = selected ? priority : null;
                        });
                      },
                      backgroundColor: _getPriorityColor(priority).withOpacity(0.2),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Task count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTasks.length} ${filteredTasks.length == 1 ? 'task' : 'tasks'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedCategory != null || _selectedPriority != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedPriority = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear filters'),
                  ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _allTasks.isEmpty 
                            ? 'No tasks yet.\nTap + to add one!'
                            : 'No tasks match your filters',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskListTile(
                        task: filteredTasks[index],
                        onToggle: () => _toggleTaskCompletion(filteredTasks[index]),
                        onDelete: () => _deleteTask(filteredTasks[index].id),
                        onEdit: () => _showTaskDialog(context, task: filteredTasks[index]),
                        onPriorityChange: (newPriority) => 
                          _updateTaskPriority(filteredTasks[index], newPriority),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (newTask) {
          if (task == null) {
            _addTask(newTask);
          } else {
            _updateTask(newTask);
          }
        },
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }
}

// Task List Tile Widget
class TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(Priority) onPriorityChange;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onPriorityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    task.category.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Priority chip (tappable)
                GestureDetector(
                  onTap: () => _showPriorityMenu(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(task.priority).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          task.priority.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getPriorityColor(task.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: _getPriorityColor(task.priority),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Days ago
                if (task.daysSinceCreation > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${task.daysSinceCreation}d ago',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  
                // Due date
                if (task.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 10, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
              onPressed: () => _confirmDelete(context),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Change Priority',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...Priority.values.map((priority) {
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(priority.label),
                trailing: priority == task.priority 
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
                onTap: () {
                  onPriorityChange(priority);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference < 0) return '${-difference}d overdue';
    
    return '${date.day}/${date.month}';
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }
}

// Task Dialog for Create/Edit
class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedCategory = widget.task?.category ?? TaskCategory.personal;
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDueDate = date;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDueDate == null
                    ? 'Set due date'
                    : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
              ),
            ),
            if (_selectedDueDate != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDueDate = null;
                  });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear due date'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }

            final newTask = Task(
              id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _selectedCategory,
              priority: _selectedPriority,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
              dueDate: _selectedDueDate,
              isDone: widget.task?.isDone ?? false,
              completedAt: widget.task?.completedAt,
            );

            widget.onSave(newTask);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
