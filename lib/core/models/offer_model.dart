import 'package:equatable/equatable.dart';

/// Type of offer
enum OfferType { bill, item, category, room, promo }

/// Type of discount calculation
enum DiscountType { percent, flat }

/// Offer Master Configuration
class Offer extends Equatable {
  final String id;
  final String name;
  final OfferType offerType;
  final DiscountType discountType;
  final double discountValue;
  final List<String> applicableItemIds;
  final List<String> applicableCategoryIds;
  final List<String> applicableDays; // e.g., ["Monday", "Tuesday"]
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm
  final DateTime? validFrom;
  final DateTime? validTo;
  final double minBillAmount;
  final double maxDiscountAmount;
  final int usageLimitPerDay;
  final bool autoApply;
  final bool isActive;
  final String? description;

  const Offer({
    required this.id,
    required this.name,
    required this.offerType,
    required this.discountType,
    required this.discountValue,
    this.applicableItemIds = const [],
    this.applicableCategoryIds = const [],
    this.applicableDays = const [],
    this.startTime,
    this.endTime,
    this.validFrom,
    this.validTo,
    this.minBillAmount = 0,
    this.maxDiscountAmount = double.infinity,
    this.usageLimitPerDay = 0, // 0 means no limit
    this.autoApply = false,
    this.isActive = true,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'offerType': offerType.name,
    'discountType': discountType.name,
    'discountValue': discountValue,
    'applicableItemIds': applicableItemIds,
    'applicableCategoryIds': applicableCategoryIds,
    'applicableDays': applicableDays,
    'startTime': startTime,
    'endTime': endTime,
    'validFrom': validFrom?.toIso8601String(),
    'validTo': validTo?.toIso8601String(),
    'minBillAmount': minBillAmount,
    'maxDiscountAmount': maxDiscountAmount == double.infinity
        ? -1
        : maxDiscountAmount,
    'usageLimitPerDay': usageLimitPerDay,
    'autoApply': autoApply,
    'isActive': isActive,
    'description': description,
  };

  factory Offer.fromJson(Map<String, dynamic> json) {
    final maxDisc = (json['maxDiscountAmount'] as num?)?.toDouble() ?? -1;
    return Offer(
      id: json['id'],
      name: json['name'],
      offerType: OfferType.values.firstWhere(
        (e) => e.name == json['offerType'],
      ),
      discountType: DiscountType.values.firstWhere(
        (e) => e.name == json['discountType'],
      ),
      discountValue: (json['discountValue'] as num).toDouble(),
      applicableItemIds: List<String>.from(json['applicableItemIds'] ?? []),
      applicableCategoryIds: List<String>.from(
        json['applicableCategoryIds'] ?? [],
      ),
      applicableDays: List<String>.from(json['applicableDays'] ?? []),
      startTime: json['startTime'],
      endTime: json['endTime'],
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'])
          : null,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
      minBillAmount: (json['minBillAmount'] as num?)?.toDouble() ?? 0,
      maxDiscountAmount: maxDisc < 0 ? double.infinity : maxDisc,
      usageLimitPerDay: json['usageLimitPerDay'] ?? 0,
      autoApply: json['autoApply'] ?? false,
      isActive: json['isActive'] ?? true,
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    offerType,
    discountType,
    discountValue,
    isActive,
  ];
}

/// Applied Bill Discount
class BillDiscount extends Equatable {
  final String id;
  final String offerId;
  final String name;
  final DiscountType discountType;
  final double discountValue;
  final double discountAmount;
  final String appliedBy;
  final String reason;
  final DateTime appliedAt;

  const BillDiscount({
    required this.id,
    required this.offerId,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.appliedBy,
    required this.reason,
    required this.appliedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offerId': offerId,
    'name': name,
    'discountType': discountType.name,
    'discountValue': discountValue,
    'discountAmount': discountAmount,
    'appliedBy': appliedBy,
    'reason': reason,
    'appliedAt': appliedAt.toIso8601String(),
  };

  factory BillDiscount.fromJson(Map<String, dynamic> json) => BillDiscount(
    id: json['id'],
    offerId: json['offerId'],
    name: json['name'],
    discountType: DiscountType.values.firstWhere(
      (e) => e.name == json['discountType'],
    ),
    discountValue: (json['discountValue'] as num).toDouble(),
    discountAmount: (json['discountAmount'] as num).toDouble(),
    appliedBy: json['appliedBy'],
    reason: json['reason'],
    appliedAt: DateTime.parse(json['appliedAt']),
  );

  @override
  List<Object?> get props => [id, offerId, discountAmount, appliedAt];
}
