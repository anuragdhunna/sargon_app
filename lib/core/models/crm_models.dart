import 'package:equatable/equatable.dart';
import 'base_entity.dart';

/// Customer model
class Customer extends BaseEntity {
  final String name;
  final String phone;
  final String? email;
  final DateTime? lastVisit;
  final int totalBookings;
  final double totalSpent;
  final String? idProofType;
  final String? idProofNumber;
  final String? idProofImageUrl;
  final LoyaltyInfo? loyaltyInfo;

  const Customer({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.phone,
    this.email,
    this.lastVisit,
    this.totalBookings = 0,
    this.totalSpent = 0.0,
    this.idProofType,
    this.idProofNumber,
    this.idProofImageUrl,
    this.loyaltyInfo,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    phone,
    email,
    lastVisit,
    totalBookings,
    totalSpent,
    idProofType,
    idProofNumber,
    idProofImageUrl,
    loyaltyInfo,
  ];

  Customer copyWith({
    String? id,
    String? hotelId,
    String? name,
    String? phone,
    String? email,
    DateTime? lastVisit,
    int? totalBookings,
    double? totalSpent,
    LoyaltyInfo? loyaltyInfo,
  }) {
    return Customer(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lastVisit: lastVisit ?? this.lastVisit,
      totalBookings: totalBookings ?? this.totalBookings,
      totalSpent: totalSpent ?? this.totalSpent,
      idProofType: idProofType,
      idProofNumber: idProofNumber,
      idProofImageUrl: idProofImageUrl,
      loyaltyInfo: loyaltyInfo ?? this.loyaltyInfo,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'name': name,
      'phone': phone,
      'email': email,
      'lastVisit': lastVisit?.toIso8601String(),
      'totalBookings': totalBookings,
      'totalSpent': totalSpent,
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'idProofImageUrl': idProofImageUrl,
      if (loyaltyInfo != null) 'loyaltyInfo': loyaltyInfo?.toJson(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      lastVisit: BaseEntity.parseDateTime(json['lastVisit']),
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      idProofType: json['idProofType'] as String?,
      idProofNumber: json['idProofNumber'] as String?,
      idProofImageUrl: json['idProofImageUrl'] as String?,
      loyaltyInfo: json['loyaltyInfo'] != null
          ? LoyaltyInfo.fromJson(Map<String, dynamic>.from(json['loyaltyInfo']))
          : null,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['createdAt'],
      ),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Loyalty Tier model
class LoyaltyTier extends BaseEntity {
  final String name;
  final double minSpend;
  final double earnMultiplier;
  final double redeemMultiplier;
  final List<String> benefits;
  final bool isActive;

  const LoyaltyTier({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.minSpend,
    required this.earnMultiplier,
    this.redeemMultiplier = 1.0,
    this.benefits = const [],
    this.isActive = true,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    minSpend,
    earnMultiplier,
    isActive,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'name': name,
    'minSpend': minSpend,
    'earnMultiplier': earnMultiplier,
    'redeemMultiplier': redeemMultiplier,
    'benefits': benefits,
    'isActive': isActive,
  };

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) => LoyaltyTier(
    id: json['id'],
    hotelId: json['hotelId'] as String? ?? 'default',
    name: json['name'],
    minSpend: (json['minSpend'] as num).toDouble(),
    earnMultiplier: (json['earnMultiplier'] as num).toDouble(),
    redeemMultiplier: (json['redeemMultiplier'] as num?)?.toDouble() ?? 1.0,
    benefits: List<String>.from(json['benefits'] ?? []),
    isActive: json['isActive'] ?? true,
    createdBy: json['createdBy'] as String?,
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'] as String?,
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );
}

/// Point Earning Rule
enum PointEarnType { billAmount, category, item }

class PointRule extends BaseEntity {
  final PointEarnType earnType;
  final double earnValue;
  final List<String> applicableCategoryIds;
  final List<String> applicableItemIds;
  final double minBillAmount;
  final bool isActive;

  const PointRule({
    required super.id,
    required super.hotelId,
    required this.earnType,
    required this.earnValue,
    this.applicableCategoryIds = const [],
    this.applicableItemIds = const [],
    this.minBillAmount = 0,
    this.isActive = true,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [...super.props, earnType, earnValue, isActive];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'earnType': earnType.name,
    'earnValue': earnValue,
    'applicableCategoryIds': applicableCategoryIds,
    'applicableItemIds': applicableItemIds,
    'minBillAmount': minBillAmount,
    'isActive': isActive,
  };

  factory PointRule.fromJson(Map<String, dynamic> json) => PointRule(
    id: json['id'],
    hotelId: json['hotelId'] as String? ?? 'default',
    earnType: PointEarnType.values.firstWhere(
      (e) => e.name == json['earnType'],
    ),
    earnValue: (json['earnValue'] as num).toDouble(),
    applicableCategoryIds: List<String>.from(
      json['applicableCategoryIds'] ?? [],
    ),
    applicableItemIds: List<String>.from(json['applicableItemIds'] ?? []),
    minBillAmount: (json['minBillAmount'] as num?)?.toDouble() ?? 0,
    isActive: json['isActive'] ?? true,
    createdBy: json['createdBy'] as String?,
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'] as String?,
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );
}

/// Point Redemption Record
class PointRedemption extends BaseEntity {
  final String billId;
  final int pointsUsed;
  final double monetaryValue;
  final DateTime redeemedAt;

  const PointRedemption({
    required super.id,
    required super.hotelId,
    required this.billId,
    required this.pointsUsed,
    required this.monetaryValue,
    required this.redeemedAt,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    billId,
    pointsUsed,
    monetaryValue,
    redeemedAt,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'billId': billId,
    'pointsUsed': pointsUsed,
    'monetaryValue': monetaryValue,
    'redeemedAt': redeemedAt.toIso8601String(),
  };

  factory PointRedemption.fromJson(Map<String, dynamic> json) =>
      PointRedemption(
        id: json['id'],
        hotelId: json['hotelId'] as String? ?? 'default',
        billId: json['billId'],
        pointsUsed: json['pointsUsed'] as int,
        monetaryValue: (json['monetaryValue'] as num).toDouble(),
        redeemedAt:
            BaseEntity.parseDateTime(json['redeemedAt']) ?? DateTime.now(),
        createdBy: json['createdBy'] as String?,
        createdOn: BaseEntity.parseDateTime(json['createdOn']),
        updatedBy: json['updatedBy'] as String?,
        updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
        isDeleted: json['isDeleted'] ?? false,
      );
}

/// Loyalty Info
class LoyaltyInfo extends Equatable {
  final String tierId;
  final int totalPoints;
  final int availablePoints;
  final double lifetimeSpend;
  final DateTime? lastActivityAt;

  const LoyaltyInfo({
    required this.tierId,
    this.totalPoints = 0,
    this.availablePoints = 0,
    this.lifetimeSpend = 0,
    this.lastActivityAt,
  });

  @override
  List<Object?> get props => [
    tierId,
    totalPoints,
    availablePoints,
    lifetimeSpend,
    lastActivityAt,
  ];

  LoyaltyInfo copyWith({
    String? tierId,
    int? totalPoints,
    int? availablePoints,
    double? lifetimeSpend,
    DateTime? lastActivityAt,
  }) {
    return LoyaltyInfo(
      tierId: tierId ?? this.tierId,
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      lifetimeSpend: lifetimeSpend ?? this.lifetimeSpend,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'tierId': tierId,
    'totalPoints': totalPoints,
    'availablePoints': availablePoints,
    'lifetimeSpend': lifetimeSpend,
    'lastActivityAt': lastActivityAt?.toIso8601String(),
  };

  factory LoyaltyInfo.fromJson(Map<String, dynamic> json) => LoyaltyInfo(
    tierId: json['tierId'],
    totalPoints: json['totalPoints'] as int? ?? 0,
    availablePoints: json['availablePoints'] as int? ?? 0,
    lifetimeSpend: (json['lifetimeSpend'] as num?)?.toDouble() ?? 0,
    lastActivityAt: BaseEntity.parseDateTime(json['lastActivityAt']),
  );
}
