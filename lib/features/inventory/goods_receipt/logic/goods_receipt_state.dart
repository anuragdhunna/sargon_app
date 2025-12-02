import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/data/goods_receipt_model.dart';

/// Base state for goods receipt management
abstract class GoodsReceiptState extends Equatable {
  const GoodsReceiptState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when goods receipts are not yet loaded
class GoodsReceiptInitial extends GoodsReceiptState {}

/// State when goods receipts are being loaded
class GoodsReceiptLoading extends GoodsReceiptState {}

/// State when goods receipts are successfully loaded
class GoodsReceiptLoaded extends GoodsReceiptState {
  final List<GoodsReceiptNote> grns;
  
  const GoodsReceiptLoaded(this.grns);
  
  @override
  List<Object?> get props => [grns];
}

/// State when an error occurs during goods receipt operations
class GoodsReceiptError extends GoodsReceiptState {
  final String message;
  
  const GoodsReceiptError(this.message);
  
  @override
  List<Object?> get props => [message];
}
