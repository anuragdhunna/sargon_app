import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {
  final String verificationId;
  final int? resendToken;

  const AuthCodeSent({required this.verificationId, this.resendToken});

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class AuthVerified extends AuthState {
  final UserRole role;
  final String userId;
  final String userName;

  const AuthVerified({
    required this.role,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [role, userId, userName];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
