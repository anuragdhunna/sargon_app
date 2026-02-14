import 'package:equatable/equatable.dart';
import 'base_entity.dart';

/// Loyalty Tier model
class LoyaltyTier extends BaseEntity {
  final String name; // e.g., Silver, Gold, Platinum
  final double minSpend;
  final double earnMultiplier; // e.g., 1.0, 1.25
  final double redeemMultiplier; // e.g., 1.0
  final List<String> benefits;
  final bool isActive;

  const LoyaltyTier({
    required String id,
    required this.name,
    required this.minSpend,
    required this.earnMultiplier,
    this.redeemMultiplier = 1.0,
    this.benefits = const [],
    this.isActive = true,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : super(
         id: id,
         createdOn: createdOn,
         createdBy: createdBy,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

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

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    minSpend,
    earnMultiplier,
    isActive,
  ];
}

/// Point Earning Rule
enum PointEarnType { bill_amount, category, item }

class PointRule extends BaseEntity {
  final PointEarnType earnType;
  final double earnValue; // points per ₹100 or flat points
  final List<String> applicableCategoryIds;
  final List<String> applicableItemIds;
  final double minBillAmount;
  final bool isActive;

  const PointRule({
    required String id,
    required this.earnType,
    required this.earnValue,
    this.applicableCategoryIds = const [],
    this.applicableItemIds = const [],
    this.minBillAmount = 0,
    this.isActive = true,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : super(
         id: id,
         createdOn: createdOn,
         createdBy: createdBy,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

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

  @override
  List<Object?> get props => [id, earnType, earnValue, isActive];
}

/// Point Redemption Record
class PointRedemption extends BaseEntity {
  final String billId;
  final int pointsUsed;
  final double monetaryValue;
  final DateTime redeemedAt;

  const PointRedemption({
    required String id,
    required this.billId,
    required this.pointsUsed,
    required this.monetaryValue,
    required this.redeemedAt,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : super(
         id: id,
         createdOn: createdOn ?? redeemedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

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

  @override
  List<Object?> get props => [
    ...super.props,
    billId,
    pointsUsed,
    monetaryValue,
  ];
}

/// Extended Customer Loyalty Info (to be stored in Customer model or as a reference)
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
    lastActivityAt: json['lastActivityAt'] != null
        ? DateTime.parse(json['lastActivityAt'])
        : null,
  );

  @override
  List<Object?> get props => [
    tierId,
    totalPoints,
    availablePoints,
    lifetimeSpend,
  ];
}
