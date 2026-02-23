import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

// States
abstract class OwnerState extends Equatable {
  const OwnerState();
  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {}

class OwnerLoading extends OwnerState {}

class OwnerLoaded extends OwnerState {
  final List<User> owners;
  const OwnerLoaded(this.owners);
  @override
  List<Object?> get props => [owners];
}

class OwnerError extends OwnerState {
  final String message;
  const OwnerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class OwnerCubit extends Cubit<OwnerState> {
  final DatabaseService _databaseService;
  StreamSubscription? _subscription;

  OwnerCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(OwnerInitial());

  void loadAllOwners() {
    emit(OwnerLoading());
    _subscription?.cancel();
    _subscription = _databaseService.streamAllOwners().listen(
      (owners) => emit(OwnerLoaded(owners)),
      onError: (e) => emit(OwnerError(e.toString())),
    );
  }

  Future<void> updateOwnerStatus(String userId, bool isActive) async {
    try {
      // For owners, hotelId might not be strictly needed for status update
      // as they are in the top-level users collection indexed by UID.
      await _databaseService.updateUserStatus('system', userId, isActive);
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
