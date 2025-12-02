import 'package:equatable/equatable.dart';

import '../../inventory_index.dart';

/// Base state for purchase order management
abstract class PurchaseOrderState extends Equatable {
  const PurchaseOrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state when purchase orders are not yet loaded
class PurchaseOrderInitial extends PurchaseOrderState {}

/// State when purchase orders are being loaded
class PurchaseOrderLoading extends PurchaseOrderState {}

/// State when purchase orders are successfully loaded
class PurchaseOrderLoaded extends PurchaseOrderState {
  final List<PurchaseOrder> orders;

  const PurchaseOrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// State when an error occurs during purchase order operations
class PurchaseOrderError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
