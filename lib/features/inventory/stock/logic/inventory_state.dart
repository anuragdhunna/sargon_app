import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';

/// Base state for inventory management
abstract class InventoryState extends Equatable {
  const InventoryState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when inventory is not yet loaded
class InventoryInitial extends InventoryState {}

/// State when inventory is being loaded
class InventoryLoading extends InventoryState {}

/// State when inventory items are successfully loaded
class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  
  const InventoryLoaded(this.items);
  
  @override
  List<Object?> get props => [items];
}

/// State when an error occurs during inventory operations
class InventoryError extends InventoryState {
  final String message;
  
  const InventoryError(this.message);
  
  @override
  List<Object?> get props => [message];
}
