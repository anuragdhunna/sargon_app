import 'package:equatable/equatable.dart';

enum UserRole { owner, manager, chef, waiter, housekeeping, maintenance, security, frontDesk }
enum UserStatus { active, inactive, onLeave }
enum PaymentType { dailyWage, monthlySalary }

class User extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? avatarUrl;
  
  // Payment fields
  final PaymentType paymentType;
  final double? dailyWage;      // For daily-wage workers
  final double? monthlySalary;   // For salaried employees

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.status = UserStatus.active,
    this.avatarUrl,
    this.paymentType = PaymentType.monthlySalary,
    this.dailyWage,
    this.monthlySalary,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, role, status, avatarUrl, paymentType, dailyWage, monthlySalary];

  // Factory for creating a dummy user
  factory User.dummy() {
    return const User(
      id: '1',
      name: 'John Doe',
      phoneNumber: '+1234567890',
      role: UserRole.waiter,
      paymentType: PaymentType.dailyWage,
      dailyWage: 500.0,
    );
  }
}
