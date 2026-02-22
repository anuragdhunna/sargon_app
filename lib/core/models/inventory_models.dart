import 'base_entity.dart';

/// Item category for inventory
enum ItemCategory { food, beverage, housekeeping, maintenance, other }

/// Unit type for inventory items
enum UnitType { kg, liters, pieces, packs, bottles }

/// Extension for ItemCategory
extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.food:
        return 'Food';
      case ItemCategory.beverage:
        return 'Beverage';
      case ItemCategory.housekeeping:
        return 'Housekeeping';
      case ItemCategory.maintenance:
        return 'Maintenance';
      case ItemCategory.other:
        return 'Other';
    }
  }
}

/// Extension for UnitType
extension UnitTypeExtension on UnitType {
  String get displayName {
    switch (this) {
      case UnitType.kg:
        return 'Kg';
      case UnitType.liters:
        return 'Liters';
      case UnitType.pieces:
        return 'Pieces';
      case UnitType.packs:
        return 'Packs';
      case UnitType.bottles:
        return 'Bottles';
    }
  }
}

/// InventoryItem model for stock management
class InventoryItem extends BaseEntity {
  final String name;
  final ItemCategory category;
  final double quantity;
  final double minQuantity;
  final UnitType unit;
  final double pricePerUnit;
  final String? imageUrl;
  final String? vendorId;
  final DateTime? lastRestockedAt;

  const InventoryItem({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
    this.vendorId,
    this.lastRestockedAt,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();

  bool get isLowStock => quantity <= minQuantity;
  bool get isOutOfStock => quantity <= 0;
  double get totalValue => quantity * pricePerUnit;

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    category,
    quantity,
    minQuantity,
    unit,
    pricePerUnit,
    imageUrl,
    vendorId,
    lastRestockedAt,
  ];

  InventoryItem copyWith({
    String? id,
    String? hotelId,
    String? name,
    ItemCategory? category,
    double? quantity,
    double? minQuantity,
    UnitType? unit,
    double? pricePerUnit,
    String? imageUrl,
    String? vendorId,
    DateTime? lastRestockedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      vendorId: vendorId ?? this.vendorId,
      lastRestockedAt: lastRestockedAt ?? this.lastRestockedAt,
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
      'category': category.name,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'unit': unit.name,
      'pricePerUnit': pricePerUnit,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
      'lastRestockedAt': lastRestockedAt?.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      name: json['name'] as String,
      category: ItemCategory.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == json['category'].toString().toLowerCase(),
        orElse: () => ItemCategory.other,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      minQuantity: (json['minQuantity'] as num).toDouble(),
      unit: UnitType.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => UnitType.pieces,
      ),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      vendorId: json['vendorId'] as String?,
      lastRestockedAt: BaseEntity.parseDateTime(json['lastRestockedAt']),
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Vendor category enum
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

/// Payment terms enum
enum PaymentTerms { immediate, net7, net15, net30, net60 }

/// Extension for VendorCategory
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

/// Extension for PaymentTerms
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

/// Vendor model for supplier management
class Vendor extends BaseEntity {
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

  const Vendor({
    required super.id,
    required super.hotelId,
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
    category,
    contactPerson,
    phoneNumber,
    email,
    address,
    paymentTerms,
    isPreferred,
    creditLimit,
    gstNumber,
  ];

  Vendor copyWith({
    String? id,
    String? hotelId,
    String? name,
    VendorCategory? category,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    PaymentTerms? paymentTerms,
    bool? isPreferred,
    double? creditLimit,
    String? gstNumber,
  }) {
    return Vendor(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      category: category ?? this.category,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      isPreferred: isPreferred ?? this.isPreferred,
      creditLimit: creditLimit ?? this.creditLimit,
      gstNumber: gstNumber ?? this.gstNumber,
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
      'category': category.name,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'paymentTerms': paymentTerms.name,
      'isPreferred': isPreferred,
      'creditLimit': creditLimit,
      'gstNumber': gstNumber,
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      name: json['name'] as String,
      category: VendorCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => VendorCategory.other,
      ),
      contactPerson: json['contactPerson'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      paymentTerms: PaymentTerms.values.firstWhere(
        (e) => e.name == json['paymentTerms'],
        orElse: () => PaymentTerms.net30,
      ),
      isPreferred: json['isPreferred'] as bool? ?? false,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      gstNumber: json['gstNumber'] as String?,
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
