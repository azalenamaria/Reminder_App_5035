// Data Models for Task Reminder App (Local Only)

// Enums for Priority and Category
enum Priority {
  low(0, 'Low'),
  medium(1, 'Medium'),
  high(2, 'High'),
  urgent(3, 'Urgent');

  final int value;
  final String label;
  const Priority(this.value, this.label);

  // Get next higher priority (for auto-escalation)
  Priority? escalate() {
    if (this == Priority.urgent) return null;
    return Priority.values[value + 1];
  }
}

enum TaskCategory {
  personal('Personal'),
  work('Work'),
  health('Health'),
  shopping('Shopping'),
  other('Other');

  final String label;
  const TaskCategory(this.label);
}

// Main Task Model
class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.isDone = false,
    this.completedAt,
  });

  // Calculate days since creation
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  // Create a copy with modified fields
  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    Priority? priority,
    DateTime? dueDate,
    bool? isDone,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Check if task should be escalated (based on days undone)
  bool shouldEscalate(int daysThreshold) {
    if (isDone) return false;
    if (priority == Priority.urgent) return false;
    return daysSinceCreation >= daysThreshold;
  }
}
