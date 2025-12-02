import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/incidents/data/incident_model.dart';
import 'package:hotel_manager/features/performance/data/performance_model.dart';
import 'package:hotel_manager/features/performance/data/performance_repository.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

// States
abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}
class PerformanceLoading extends PerformanceState {}
class PerformanceLoaded extends PerformanceState {
  final List<EmployeePerformance> performances;
  
  const PerformanceLoaded(this.performances);
  
  @override
  List<Object?> get props => [performances];
}
class PerformanceError extends PerformanceState {
  final String message;
  
  const PerformanceError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class PerformanceCubit extends Cubit<PerformanceState> {
  final PerformanceRepository _repository;
  
  PerformanceCubit({PerformanceRepository? repository})
      : _repository = repository ?? PerformanceRepository(),
        super(PerformanceInitial());
  
  Future<void> loadPerformances(
    List<User> users,
    List<Checklist> checklists,
    List<Incident> incidents,
  ) async {
    emit(PerformanceLoading());
    try {
      final performances = await _repository.getAllEmployeesPerformance(
        users,
        checklists,
        incidents,
      );
      emit(PerformanceLoaded(performances));
    } catch (e) {
      emit(PerformanceError(e.toString()));
    }
  }
  
  Future<EmployeePerformance?> getEmployeePerformance(
    User user,
    List<Checklist> checklists,
    List<Incident> incidents,
  ) async {
    try {
      return await _repository.getEmployeePerformance(user, checklists, incidents);
    } catch (e) {
      return null;
    }
  }
}
