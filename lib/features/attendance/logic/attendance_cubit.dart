import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> history;
  final bool isCheckedIn;
  
  const AttendanceLoaded({required this.history, required this.isCheckedIn});
  
  @override
  List<Object?> get props => [history, isCheckedIn];
}
class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;
  final String _currentUserId = '1'; // Mock current user

  AttendanceCubit({AttendanceRepository? repository}) 
      : _repository = repository ?? AttendanceRepository(),
        super(AttendanceInitial()) {
    loadAttendance();
  }

  void loadAttendance() async {
    emit(AttendanceLoading());
    try {
      final history = await _repository.getHistory(_currentUserId);
      final isCheckedIn = await _repository.isCheckedIn(_currentUserId);
      emit(AttendanceLoaded(history: history, isCheckedIn: isCheckedIn));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  void punch(AttendanceType type) async {
    emit(AttendanceLoading());
    try {
      await _repository.punch(_currentUserId, type);
      // Reload to get fresh state
      loadAttendance();
    } catch (e) {
      // If error (e.g. location), emit error but then reload old state or stay in error?
      // Better to emit error then reload so user sees the snackbar
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
      // Re-fetch state after a short delay or let UI handle retry
      final history = await _repository.getHistory(_currentUserId);
      final isCheckedIn = await _repository.isCheckedIn(_currentUserId);
      emit(AttendanceLoaded(history: history, isCheckedIn: isCheckedIn));
    }
  }

  Future<void> regularizeAttendance({
    required String userId,
    required DateTime date,
    required AttendanceType type,
    required String reason,
  }) async {
    emit(AttendanceLoading());
    try {
      await _repository.regularize(userId, date, type, reason);
      // If regularizing for self (which shouldn't happen per new rules but for safety), reload.
      // If regularizing for others, we might not need to reload *my* attendance, 
      // but maybe we should show a success message.
      // For now, just reload to be safe if we are viewing that user's history (future feature).
      if (userId == _currentUserId) {
        loadAttendance();
      } else {
        // Just emit loaded with current history to stop loading spinner
        final history = await _repository.getHistory(_currentUserId);
        final isCheckedIn = await _repository.isCheckedIn(_currentUserId);
        emit(AttendanceLoaded(history: history, isCheckedIn: isCheckedIn));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
      loadAttendance();
    }
  }
}
