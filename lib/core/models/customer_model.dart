import 'package:equatable/equatable.dart';

import 'loyalty_model.dart';

/// Customer model for marketing and analytics
class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastVisit;
  final int totalBookings;
  final double totalSpent;
  final String? idProofType;
  final String? idProofNumber;
  final String? idProofImageUrl;
  final LoyaltyInfo? loyaltyInfo;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.createdAt,
    this.lastVisit,
    this.totalBookings = 0,
    this.totalSpent = 0.0,
    this.idProofType,
    this.idProofNumber,
    this.idProofImageUrl,
    this.loyaltyInfo,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    createdAt,
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
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      totalBookings: totalBookings ?? this.totalBookings,
      totalSpent: totalSpent ?? this.totalSpent,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      idProofImageUrl: idProofImageUrl ?? this.idProofImageUrl,
      loyaltyInfo: loyaltyInfo ?? this.loyaltyInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'])
          : null,
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      idProofType: json['idProofType'] as String?,
      idProofNumber: json['idProofNumber'] as String?,
      idProofImageUrl: json['idProofImageUrl'] as String?,
      loyaltyInfo: json['loyaltyInfo'] != null
          ? LoyaltyInfo.fromJson(Map<String, dynamic>.from(json['loyaltyInfo']))
          : null,
    );
  }
}
