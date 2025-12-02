import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/incidents/data/incident_model.dart';

// States
abstract class IncidentState extends Equatable {
  const IncidentState();
  @override
  List<Object?> get props => [];
}

class IncidentInitial extends IncidentState {}
class IncidentLoading extends IncidentState {}
class IncidentLoaded extends IncidentState {
  final List<Incident> incidents;
  const IncidentLoaded(this.incidents);
  @override
  List<Object?> get props => [incidents];
}

// Cubit
class IncidentCubit extends Cubit<IncidentState> {
  IncidentCubit() : super(IncidentInitial()) {
    loadIncidents();
  }

  final List<Incident> _mockIncidents = [
    Incident(
      id: '1',
      title: 'AC Not Cooling',
      description: 'Guest in Room 302 complained about AC.',
      reportedBy: 'Front Desk',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      priority: IncidentPriority.high,
      status: IncidentStatus.open,
      location: 'Room 302',
    ),
    Incident(
      id: '2',
      title: 'Leaking Tap',
      description: 'Lobby washroom tap is leaking.',
      reportedBy: 'Housekeeping',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      priority: IncidentPriority.low,
      status: IncidentStatus.resolved,
      location: 'Lobby Washroom',
    ),
  ];

  void loadIncidents() async {
    emit(IncidentLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(IncidentLoaded(List.from(_mockIncidents)));
  }

  void reportIncident(Incident incident, {required String userId, required String userName, required String userRole}) {
    _mockIncidents.insert(0, incident);
    emit(IncidentLoaded(List.from(_mockIncidents)));
    
    AuditService().log(
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.create,
      entity: 'incident',
      entityId: incident.id,
      description: 'Reported incident: ${incident.title}',
      metadata: {'priority': incident.priority.name, 'location': incident.location},
    );
  }

  void resolveIncident(String id, {required String userId, required String userName, required String userRole}) {
    final index = _mockIncidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _mockIncidents[index] = _mockIncidents[index].copyWith(status: IncidentStatus.resolved);
      emit(IncidentLoaded(List.from(_mockIncidents)));
      
      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.update,
        entity: 'incident',
        entityId: id,
        description: 'Resolved incident: ${_mockIncidents[index].title}',
      );
    }
  }
}
