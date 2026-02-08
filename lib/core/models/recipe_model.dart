import 'package:equatable/equatable.dart';
import '../../core/models/inventory_item_model.dart';

/// Represents an ingredient used in a menu item recipe
class RecipeIngredient extends Equatable {
  final String inventoryItemId;
  final String name; // Snapshot of name for display even if inventory deleted
  final double quantity;
  final UnitType unit;

  const RecipeIngredient({
    required this.inventoryItemId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'inventoryItemId': inventoryItemId,
      'name': name,
      'quantity': quantity,
      'unit': unit.name,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      inventoryItemId: json['inventoryItemId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: UnitType.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => UnitType.pieces,
      ),
    );
  }

  @override
  List<Object?> get props => [inventoryItemId, name, quantity, unit];
}
