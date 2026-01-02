import 'package:equatable/equatable.dart';

/// User roles in the hotel management system
enum UserRole {
  owner,
  manager,
  chef,
  waiter,
  housekeeping,
  maintenance,
  security,
  frontDesk,
}

/// Extension to get display names for UserRole
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.chef:
        return 'Chef';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.housekeeping:
        return 'Housekeeping';
      case UserRole.maintenance:
        return 'Maintenance';
      case UserRole.security:
        return 'Security';
      case UserRole.frontDesk:
        return 'Front Desk';
    }
  }
}

/// User account status
enum UserStatus { active, inactive, onLeave }

/// Payment type for employees
enum PaymentType { dailyWage, monthlySalary }

/// User model representing staff members in the hotel
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class User extends Equatable {
  final String id;
  final String? email; // For Firebase Auth
  final String name;
  final String phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? avatarUrl;

  // Payment fields
  final PaymentType paymentType;
  final double? dailyWage;
  final double? monthlySalary;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Schema version for migrations
  static const int schemaVersion = 1;

  const User({
    required this.id,
    this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.status = UserStatus.active,
    this.avatarUrl,
    this.paymentType = PaymentType.monthlySalary,
    this.dailyWage,
    this.monthlySalary,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phoneNumber,
    role,
    status,
    avatarUrl,
    paymentType,
    dailyWage,
    monthlySalary,
    createdAt,
    updatedAt,
  ];

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    String? avatarUrl,
    PaymentType? paymentType,
    double? dailyWage,
    double? monthlySalary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      paymentType: paymentType ?? this.paymentType,
      dailyWage: dailyWage ?? this.dailyWage,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'status': status.name,
      'avatarUrl': avatarUrl,
      'paymentType': paymentType.name,
      'dailyWage': dailyWage,
      'monthlySalary': monthlySalary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.waiter,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == json['paymentType'],
        orElse: () => PaymentType.monthlySalary,
      ),
      dailyWage: (json['dailyWage'] as num?)?.toDouble(),
      monthlySalary: (json['monthlySalary'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Factory for creating a dummy user (for testing)
  factory User.dummy() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      role: UserRole.waiter,
      paymentType: PaymentType.dailyWage,
      dailyWage: 500.0,
      createdAt: DateTime.now(),
    );
  }
}
