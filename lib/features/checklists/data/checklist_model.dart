import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

enum ChecklistStatus { pending, inProgress, completed, overdue }
enum RecurrencePattern { none, daily, weekly, monthly, quarterly }
enum ChecklistType { housekeeping, maintenance, security, general }

class ChecklistItem extends Equatable {
  final String id;
  final String task;
  final bool isCompleted;

  const ChecklistItem({required this.id, required this.task, this.isCompleted = false});

  ChecklistItem copyWith({bool? isCompleted}) {
    return ChecklistItem(id: id, task: task, isCompleted: isCompleted ?? this.isCompleted);
  }

  @override
  List<Object?> get props => [id, task, isCompleted];
}

class Checklist extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChecklistType type;
  final ChecklistStatus status;
  final UserRole assignedRole; // e.g., assign to all Waiters or Housekeeping
  final DateTime dueDate;
  final List<ChecklistItem> items;
  
  // Enhanced fields
  final bool isTimeBound;
  final RecurrencePattern recurrence;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final String? completedBy;  // User ID who completed it
  final String? crossRoleReason;  // Reason if completed by different role

  Checklist({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.assignedRole,
    required this.dueDate,
    required this.items,
    this.isTimeBound = true,
    this.recurrence = RecurrencePattern.none,
    DateTime? createdAt,
    this.lastModifiedAt,
    this.completedBy,
    this.crossRoleReason,
  }) : createdAt = createdAt ?? DateTime.now();

  Checklist copyWith({
    String? id,
    String? title,
    String? description,
    ChecklistType? type,
    ChecklistStatus? status,
    UserRole? assignedRole,
    DateTime? dueDate,
    List<ChecklistItem>? items,
    bool? isTimeBound,
    RecurrencePattern? recurrence,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? completedBy,
    String? crossRoleReason,
  }) {
    return Checklist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedRole: assignedRole ?? this.assignedRole,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      isTimeBound: isTimeBound ?? this.isTimeBound,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
      completedBy: completedBy ?? this.completedBy,
      crossRoleReason: crossRoleReason ?? this.crossRoleReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        assignedRole,
        dueDate,
        items,
        isTimeBound,
        recurrence,
        createdAt,
        lastModifiedAt,
        completedBy,
        crossRoleReason,
      ];
}
