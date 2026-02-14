import 'base_entity.dart';

import 'loyalty_model.dart';

/// Customer model for marketing and analytics
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
    required String id,
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
    String? createdBy,
    DateTime? createdAt,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : super(
         id: id,
         createdBy: createdBy,
         createdOn: createdOn ?? createdAt,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

  /// Getter for backward compatibility
  DateTime? get createdAt => createdOn;

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
    String? name,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? lastVisit,
    int? totalBookings,
    double? totalSpent,
    String? idProofType,
    String? idProofNumber,
    String? idProofImageUrl,
    LoyaltyInfo? loyaltyInfo,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lastVisit: lastVisit ?? this.lastVisit,
      totalBookings: totalBookings ?? this.totalBookings,
      totalSpent: totalSpent ?? this.totalSpent,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      idProofImageUrl: idProofImageUrl ?? this.idProofImageUrl,
      loyaltyInfo: loyaltyInfo ?? this.loyaltyInfo,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

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
