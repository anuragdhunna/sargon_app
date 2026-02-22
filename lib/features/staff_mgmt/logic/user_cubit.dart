import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/core/services/database_service.dart';

// States
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final List<User> allUsers; // Kept for filtering
  const UserLoaded(this.users, {this.allUsers = const []});
  @override
  List<Object?> get props => [users, allUsers];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  final DatabaseService _databaseService;
  StreamSubscription? _usersSubscription;

  UserCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(UserInitial());

  void loadUsers(String hotelId) {
    emit(UserLoading());
    _usersSubscription?.cancel();
    _usersSubscription = _databaseService
        .streamUsers(hotelId)
        .listen(
          (users) {
            emit(UserLoaded(users, allUsers: users));
          },
          onError: (error) {
            emit(UserError(error.toString()));
          },
        );
  }

  Future<void> addUser(User user) async {
    await _databaseService.saveUser(user);
  }

  Future<void> toggleUserStatus(
    String hotelId,
    String userId,
    bool isActive,
  ) async {
    try {
      await _databaseService.updateUserStatus(hotelId, userId, isActive);
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> deleteUser(String hotelId, String userId) async {
    try {
      await _databaseService.deleteUser(hotelId, userId);
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void filterUsers(UserRole? role) {
    final currentState = state;
    if (currentState is UserLoaded) {
      if (role == null) {
        emit(
          UserLoaded(currentState.allUsers, allUsers: currentState.allUsers),
        );
      } else {
        final filtered = currentState.allUsers
            .where((u) => u.role == role)
            .toList();
        emit(UserLoaded(filtered, allUsers: currentState.allUsers));
      }
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
