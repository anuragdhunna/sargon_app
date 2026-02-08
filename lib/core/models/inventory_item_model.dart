import 'package:equatable/equatable.dart';

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
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class InventoryItem extends Equatable {
  final String id;
  final String name;
  final ItemCategory category;
  final double quantity;
  final double minQuantity;
  final UnitType unit;
  final double pricePerUnit;
  final String? imageUrl;
  final String? vendorId;
  final DateTime? lastRestockedAt;

  // Schema version for migrations
  static const int schemaVersion = 1;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
    this.vendorId,
    this.lastRestockedAt,
  });

  bool get isLowStock => quantity <= minQuantity;
  bool get isOutOfStock => quantity <= 0;
  double get totalValue => quantity * pricePerUnit;

  @override
  List<Object?> get props => [
    id,
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
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      vendorId: vendorId ?? this.vendorId,
      lastRestockedAt: lastRestockedAt ?? this.lastRestockedAt,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'unit': unit.name,
      'pricePerUnit': pricePerUnit,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
      'lastRestockedAt': lastRestockedAt?.toIso8601String(),
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
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
      lastRestockedAt: json['lastRestockedAt'] != null
          ? DateTime.parse(json['lastRestockedAt'] as String)
          : null,
    );
  }
}
