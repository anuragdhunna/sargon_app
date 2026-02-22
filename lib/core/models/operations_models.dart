import 'package:equatable/equatable.dart';
import 'base_entity.dart';
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
class Checklist extends BaseEntity {
  final String title;
  final String description;
  final ChecklistType type;
  final ChecklistStatus status;
  final UserRole assignedRole;
  final DateTime dueDate;
  final List<ChecklistItem> items;
  final bool isTimeBound;
  final RecurrencePattern recurrence;
  final DateTime? lastModifiedAt;
  final String? completedBy;
  final String? crossRoleReason;
  final Map<String, dynamic>? metadata;

  const Checklist({
    required super.id,
    required super.hotelId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.assignedRole,
    required this.dueDate,
    required this.items,
    this.isTimeBound = true,
    this.recurrence = RecurrencePattern.none,
    this.lastModifiedAt,
    this.completedBy,
    this.crossRoleReason,
    this.metadata,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  double get completionPercentage {
    if (items.isEmpty) return 0;
    final completed = items.where((item) => item.isCompleted).length;
    return (completed / items.length) * 100;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    title,
    description,
    type,
    status,
    assignedRole,
    dueDate,
    items,
    isTimeBound,
    recurrence,
    lastModifiedAt,
    completedBy,
    crossRoleReason,
    metadata,
  ];

  Checklist copyWith({
    String? id,
    String? hotelId,
    String? title,
    String? description,
    ChecklistType? type,
    ChecklistStatus? status,
    UserRole? assignedRole,
    bool? isTimeBound,
    RecurrencePattern? recurrence,
    List<ChecklistItem>? items,
    DateTime? lastModifiedAt,
    String? completedBy,
  }) {
    return Checklist(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedRole: assignedRole ?? this.assignedRole,
      dueDate: dueDate,
      items: items ?? this.items,
      isTimeBound: isTimeBound ?? this.isTimeBound,
      recurrence: recurrence ?? this.recurrence,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      completedBy: completedBy ?? this.completedBy,
      metadata: metadata,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'assignedRole': assignedRole.name,
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'isTimeBound': isTimeBound,
      'recurrence': recurrence.name,
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'completedBy': completedBy,
      'crossRoleReason': crossRoleReason,
      'metadata': metadata,
    };
  }

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotelId'] as String? ?? 'default',
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
      dueDate: BaseEntity.parseDateTime(json['dueDate']) ?? DateTime.now(),
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
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['createdAt'],
      ),
      lastModifiedAt: BaseEntity.parseDateTime(json['lastModifiedAt']),
      completedBy: json['completedBy']?.toString(),
      crossRoleReason: json['crossRoleReason']?.toString(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Incident priority enum
enum IncidentPriority { low, medium, high, critical }

/// Incident status enum
enum IncidentStatus { open, inProgress, resolved }

/// Extension for IncidentPriority
extension IncidentPriorityExtension on IncidentPriority {
  String get displayName {
    switch (this) {
      case IncidentPriority.low:
        return 'Low';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.high:
        return 'High';
      case IncidentPriority.critical:
        return 'Critical';
    }
  }
}

/// Extension for IncidentStatus
extension IncidentStatusExtension on IncidentStatus {
  String get displayName {
    switch (this) {
      case IncidentStatus.open:
        return 'Open';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }
}

/// Incident model for issue reporting
class Incident extends BaseEntity {
  final String title;
  final String description;
  final String reportedBy;
  final String? reportedByName;
  final DateTime timestamp;
  final IncidentPriority priority;
  final IncidentStatus status;
  final String? location;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  const Incident({
    required super.id,
    required super.hotelId,
    required this.title,
    required this.description,
    required this.reportedBy,
    this.reportedByName,
    required this.timestamp,
    required this.priority,
    required this.status,
    this.location,
    this.assignedTo,
    this.assignedToName,
    this.resolvedAt,
    this.resolutionNotes,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    title,
    description,
    reportedBy,
    reportedByName,
    timestamp,
    priority,
    status,
    location,
    assignedTo,
    assignedToName,
    resolvedAt,
    resolutionNotes,
  ];

  Incident copyWith({
    String? id,
    String? hotelId,
    IncidentStatus? status,
    String? assignedTo,
    String? resolutionNotes,
  }) {
    return Incident(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      title: title,
      description: description,
      reportedBy: reportedBy,
      timestamp: timestamp,
      priority: priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'title': title,
      'description': description,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'location': location,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
    };
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      title: json['title'] as String,
      description: json['description'] as String,
      reportedBy: json['reportedBy'] as String,
      reportedByName: json['reportedByName'] as String?,
      timestamp: BaseEntity.parseDateTime(json['timestamp']) ?? DateTime.now(),
      priority: IncidentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => IncidentPriority.medium,
      ),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IncidentStatus.open,
      ),
      location: json['location'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      resolvedAt: BaseEntity.parseDateTime(json['resolvedAt']),
      resolutionNotes: json['resolutionNotes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['timestamp'],
      ),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
