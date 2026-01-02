import 'package:equatable/equatable.dart';

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
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class Incident extends Equatable {
  final String id;
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

  // Schema version for migrations
  static const int schemaVersion = 1;

  const Incident({
    required this.id,
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
  });

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    String? reportedBy,
    String? reportedByName,
    DateTime? timestamp,
    IncidentPriority? priority,
    IncidentStatus? status,
    String? location,
    String? assignedTo,
    String? assignedToName,
    DateTime? resolvedAt,
    String? resolutionNotes,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  @override
  List<Object?> get props => [
    id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      '_schemaVersion': schemaVersion,
    };
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reportedBy: json['reportedBy'] as String,
      reportedByName: json['reportedByName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
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
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      resolutionNotes: json['resolutionNotes'] as String?,
    );
  }
}
