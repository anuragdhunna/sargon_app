import 'base_entity.dart';

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
  superAdmin,
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
      case UserRole.superAdmin:
        return 'Super Admin';
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
class User extends BaseEntity {
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

  // Schema version for migrations
  static const int schemaVersion = 1;

  const User({
    required super.id,
    required super.hotelId,
    this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.status = UserStatus.active,
    this.avatarUrl,
    this.paymentType = PaymentType.monthlySalary,
    this.dailyWage,
    this.monthlySalary,
    DateTime? createdAt,
    DateTime? createdOn,
    DateTime? updatedAt,
    DateTime? updatedOn,
    super.createdBy,
    super.updatedBy,
    super.isDeleted,
  }) : super(
         createdOn: createdOn ?? createdAt,
         updatedOn: updatedOn ?? updatedAt,
       );

  /// Getters for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();
  DateTime? get updatedAt => updatedOn;

  @override
  List<Object?> get props => [
    ...super.props,
    email,
    name,
    phoneNumber,
    role,
    status,
    avatarUrl,
    paymentType,
    dailyWage,
    monthlySalary,
  ];

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? hotelId,
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
      hotelId: hotelId ?? this.hotelId,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      paymentType: paymentType ?? this.paymentType,
      dailyWage: dailyWage ?? this.dailyWage,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      createdOn: createdAt ?? createdOn,
      updatedOn: updatedAt ?? updatedOn,
      createdBy: createdBy,
      updatedBy: updatedBy,
      isDeleted: isDeleted,
    );
  }

  /// Convert to JSON for Firebase
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'status': status.name,
      'avatarUrl': avatarUrl,
      'paymentType': paymentType.name,
      'dailyWage': dailyWage,
      'monthlySalary': monthlySalary,
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'unknown',
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
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['createdAt'],
      ),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(
        json['updatedOn'] ?? json['updatedAt'],
      ),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  /// Factory for creating a dummy user (for testing)
  factory User.dummy() {
    return User(
      id: '1',
      hotelId: 'persona_hotel',
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
