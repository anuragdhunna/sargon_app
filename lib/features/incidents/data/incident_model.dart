import 'package:equatable/equatable.dart';

enum IncidentPriority { low, medium, high, critical }
enum IncidentStatus { open, inProgress, resolved }

class Incident extends Equatable {
  final String id;
  final String title;
  final String description;
  final String reportedBy;
  final DateTime timestamp;
  final IncidentPriority priority;
  final IncidentStatus status;
  final String? location; // e.g., Room 101

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.reportedBy,
    required this.timestamp,
    required this.priority,
    required this.status,
    this.location,
  });

  Incident copyWith({IncidentStatus? status}) {
    return Incident(
      id: id,
      title: title,
      description: description,
      reportedBy: reportedBy,
      timestamp: timestamp,
      priority: priority,
      status: status ?? this.status,
      location: location,
    );
  }

  @override
  List<Object?> get props => [id, title, description, reportedBy, timestamp, priority, status, location];
}
