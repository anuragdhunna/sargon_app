import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'dart:async';

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
  final DatabaseService _databaseService;
  StreamSubscription? _incidentsSubscription;

  IncidentCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(IncidentInitial());

  void loadIncidents(String hotelId) {
    emit(IncidentLoading());
    _incidentsSubscription?.cancel();
    _incidentsSubscription = _databaseService
        .streamIncidents(hotelId)
        .listen(
          (incidents) {
            emit(IncidentLoaded(incidents));
          },
          onError: (error) {
            emit(IncidentError(error.toString()));
          },
        );
  }

  Future<void> reportIncident(
    Incident incident, {
    required String userId,
    required String userName,
    required String userRole,
    required String hotelId,
  }) async {
    await _databaseService.saveIncident(incident);

    AuditService().log(
      hotelId: hotelId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.create,
      entity: 'incident',
      entityId: incident.id,
      description: 'Reported incident: ${incident.title}',
      metadata: {
        'priority': incident.priority.name,
        'location': incident.location,
      },
    );
  }

  Future<void> resolveIncident(
    String id, {
    required String userId,
    required String userName,
    required String userRole,
    required String hotelId,
  }) async {
    await _databaseService.updateIncidentStatus(
      hotelId,
      id,
      IncidentStatus.resolved.name,
    );

    AuditService().log(
      hotelId: hotelId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.update,
      entity: 'incident',
      entityId: id,
      description: 'Resolved incident: $id',
    );
  }

  @override
  Future<void> close() {
    _incidentsSubscription?.cancel();
    return super.close();
  }
}

// Error state
class IncidentError extends IncidentState {
  final String message;
  const IncidentError(this.message);
  @override
  List<Object?> get props => [message];
}
