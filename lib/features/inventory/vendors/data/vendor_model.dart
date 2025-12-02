import 'package:equatable/equatable.dart';

enum VendorCategory {
  dairy,
  vegetables,
  fruits,
  beverages,
  meat,
  dryGoods,
  housekeeping,
  maintenance,
  other,
}

enum PaymentTerms {
  immediate,
  net7,
  net15,
  net30,
  net60,
}

class Vendor extends Equatable {
  final String id;
  final String name;
  final VendorCategory category;
  final String contactPerson;
  final String phoneNumber;
  final String? email;
  final String? address;
  final PaymentTerms paymentTerms;
  final bool isPreferred;
  final double? creditLimit;
  final String? gstNumber;
  final DateTime createdAt;

  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.contactPerson,
    required this.phoneNumber,
    this.email,
    this.address,
    this.paymentTerms = PaymentTerms.net30,
    this.isPreferred = false,
    this.creditLimit,
    this.gstNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        contactPerson,
        phoneNumber,
        email,
        address,
        paymentTerms,
        isPreferred,
        creditLimit,
        gstNumber,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'paymentTerms': paymentTerms.name,
      'isPreferred': isPreferred,
      'creditLimit': creditLimit,
      'gstNumber': gstNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      category: VendorCategory.values.firstWhere((e) => e.name == json['category']),
      contactPerson: json['contactPerson'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      paymentTerms: PaymentTerms.values.firstWhere((e) => e.name == json['paymentTerms']),
      isPreferred: json['isPreferred'] as bool,
      creditLimit: json['creditLimit'] as double?,
      gstNumber: json['gstNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

extension VendorCategoryExtension on VendorCategory {
  String get displayName {
    switch (this) {
      case VendorCategory.dairy:
        return 'Dairy Products';
      case VendorCategory.vegetables:
        return 'Vegetables';
      case VendorCategory.fruits:
        return 'Fruits';
      case VendorCategory.beverages:
        return 'Beverages';
      case VendorCategory.meat:
        return 'Meat & Poultry';
      case VendorCategory.dryGoods:
        return 'Dry Goods';
      case VendorCategory.housekeeping:
        return 'Housekeeping Supplies';
      case VendorCategory.maintenance:
        return 'Maintenance Supplies';
      case VendorCategory.other:
        return 'Other';
    }
  }
}

extension PaymentTermsExtension on PaymentTerms {
  String get displayName {
    switch (this) {
      case PaymentTerms.immediate:
        return 'Immediate';
      case PaymentTerms.net7:
        return 'Net 7 Days';
      case PaymentTerms.net15:
        return 'Net 15 Days';
      case PaymentTerms.net30:
        return 'Net 30 Days';
      case PaymentTerms.net60:
        return 'Net 60 Days';
    }
  }
}
