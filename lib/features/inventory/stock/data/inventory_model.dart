import 'package:equatable/equatable.dart';

enum ItemCategory { food, beverage, housekeeping, maintenance, other }
enum UnitType { kg, liters, pieces, packs, bottles }

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final ItemCategory category;
  final double quantity;
  final double minQuantity; // Par level
  final UnitType unit;
  final double pricePerUnit;
  final String? imageUrl;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
  });

  bool get isLowStock => quantity <= minQuantity;

  @override
  List<Object?> get props => [id, name, category, quantity, minQuantity, unit, pricePerUnit, imageUrl];
}
