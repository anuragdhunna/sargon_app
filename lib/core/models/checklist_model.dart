import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Checklist status enum
enum ChecklistStatus { pending, inProgress, completed, overdue }

/// Recurrence pattern for checklists
enum RecurrencePattern { none, daily, weekly, monthly, quarterly }

/// Checklist type enum
enum ChecklistType { housekeeping, maintenance, security, general }

/// Extension for ChecklistStatus
extension ChecklistStatusExtension on ChecklistStatus {
  String get displayName {
    switch (this) {
      case ChecklistStatus.pending:
        return 'Pending';
      case ChecklistStatus.inProgress:
        return 'In Progress';
      case ChecklistStatus.completed:
        return 'Completed';
      case ChecklistStatus.overdue:
        return 'Overdue';
    }
  }
}

/// Extension for ChecklistType
extension ChecklistTypeExtension on ChecklistType {
  String get displayName {
    switch (this) {
      case ChecklistType.housekeeping:
        return 'Housekeeping';
      case ChecklistType.maintenance:
        return 'Maintenance';
      case ChecklistType.security:
        return 'Security';
      case ChecklistType.general:
        return 'General';
    }
  }
}

/// Checklist item model
class ChecklistItem extends Equatable {
  final String id;
  final String task;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;

  const ChecklistItem({
    required this.id,
    required this.task,
    this.isCompleted = false,
    this.completedAt,
    this.completedBy,
  });

  ChecklistItem copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    String? completedBy,
  }) {
    return ChecklistItem(
      id: id,
      task: task,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id']?.toString() ?? '',
      task: json['task']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      completedBy: json['completedBy']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, task, isCompleted, completedAt, completedBy];
}

/// Checklist model
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class Checklist extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChecklistType type;
  final ChecklistStatus status;
  final UserRole assignedRole;
  final DateTime dueDate;
  final List<ChecklistItem> items;
  final bool isTimeBound;
  final RecurrencePattern recurrence;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final String? completedBy;
  final String? crossRoleReason;
  final Map<String, dynamic>? metadata;

  // Schema version for migrations
  static const int schemaVersion = 1;

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
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  double get completionPercentage {
    if (items.isEmpty) return 0;
    final completed = items.where((item) => item.isCompleted).length;
    return (completed / items.length) * 100;
  }

  bool get isFullyCompleted => items.every((item) => item.isCompleted);

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
    Map<String, dynamic>? metadata,
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
      metadata: metadata ?? this.metadata,
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
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'assignedRole': assignedRole.name,
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'isTimeBound': isTimeBound,
      'recurrence': recurrence.name,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'completedBy': completedBy,
      'crossRoleReason': crossRoleReason,
      'metadata': metadata,
      '_schemaVersion': schemaVersion,
    };
  }

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: ChecklistType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChecklistType.general,
      ),
      status: ChecklistStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChecklistStatus.pending,
      ),
      assignedRole: UserRole.values.firstWhere(
        (e) => e.name == json['assignedRole'],
        orElse: () => UserRole.waiter,
      ),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now(),
      items:
          (json['items'] as List?)
              ?.map(
                (item) => ChecklistItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          [],
      isTimeBound: json['isTimeBound'] == true,
      recurrence: RecurrencePattern.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => RecurrencePattern.none,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.tryParse(json['lastModifiedAt'].toString())
          : null,
      completedBy: json['completedBy']?.toString(),
      crossRoleReason: json['crossRoleReason']?.toString(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }
}
