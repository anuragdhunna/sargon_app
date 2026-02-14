import 'base_entity.dart';
import 'offer_model.dart';

/// Happy Hour Configuration
class HappyHour extends BaseEntity {
  final String name;
  final List<String> applicableDays;
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final List<String> applicableCategoryIds;
  final List<String> applicableItemIds;
  final DiscountType discountType;
  final double discountValue;
  final List<String> outletIds;
  final bool autoApply;
  final int priority; // higher wins if overlapping
  final bool isActive;

  const HappyHour({
    required String id,
    required this.name,
    required this.applicableDays,
    required this.startTime,
    required this.endTime,
    this.applicableCategoryIds = const [],
    this.applicableItemIds = const [],
    required this.discountType,
    required this.discountValue,
    this.outletIds = const [],
    this.autoApply = true,
    this.priority = 0,
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
    'applicableDays': applicableDays,
    'startTime': startTime,
    'endTime': endTime,
    'applicableCategoryIds': applicableCategoryIds,
    'applicableItemIds': applicableItemIds,
    'discountType': discountType.name,
    'discountValue': discountValue,
    'outletIds': outletIds,
    'autoApply': autoApply,
    'priority': priority,
    'isActive': isActive,
  };

  factory HappyHour.fromJson(Map<String, dynamic> json) => HappyHour(
    id: json['id'],
    name: json['name'],
    applicableDays: List<String>.from(json['applicableDays'] ?? []),
    startTime: json['startTime'],
    endTime: json['endTime'],
    applicableCategoryIds: List<String>.from(
      json['applicableCategoryIds'] ?? [],
    ),
    applicableItemIds: List<String>.from(json['applicableItemIds'] ?? []),
    discountType: DiscountType.values.firstWhere(
      (e) => e.name == json['discountType'],
    ),
    discountValue: (json['discountValue'] as num).toDouble(),
    outletIds: List<String>.from(json['outletIds'] ?? []),
    autoApply: json['autoApply'] ?? true,
    priority: json['priority'] ?? 0,
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
    applicableDays,
    startTime,
    endTime,
    priority,
    isActive,
  ];
}
