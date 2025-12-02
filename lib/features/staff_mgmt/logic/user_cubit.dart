import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

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
  const UserLoaded(this.users);
  @override
  List<Object?> get props => [users];
}
class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final List<User> _mockUsers = [
    const User(id: '1', name: 'Alice Manager', phoneNumber: '+123', role: UserRole.manager, status: UserStatus.active),
    const User(id: '2', name: 'Bob Chef', phoneNumber: '+124', role: UserRole.chef, status: UserStatus.active),
  ];

  void loadUsers() async {
    emit(UserLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    emit(UserLoaded(List.from(_mockUsers)));
  }

  void addUser(User user) async {
    emit(UserLoading());
    await Future.delayed(const Duration(seconds: 1));
    _mockUsers.add(user);
    emit(UserLoaded(List.from(_mockUsers)));
  }

  void deleteUser(String userId) async {
    emit(UserLoading());
    await Future.delayed(const Duration(seconds: 1));
    _mockUsers.removeWhere((u) => u.id == userId);
    emit(UserLoaded(List.from(_mockUsers)));
  }

  void filterUsers(UserRole? role) {
    if (role == null) {
      emit(UserLoaded(List.from(_mockUsers)));
    } else {
      final filtered = _mockUsers.where((u) => u.role == role).toList();
      emit(UserLoaded(filtered));
    }
  }
}
