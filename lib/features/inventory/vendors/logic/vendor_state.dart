import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/inventory/vendors/data/vendor_model.dart';

/// Base state for vendor management
abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VendorInitial extends VendorState {}

/// Loading state
class VendorLoading extends VendorState {}

/// Loaded state with vendor list
class VendorLoaded extends VendorState {
  final List<Vendor> vendors;

  const VendorLoaded(this.vendors);

  @override
  List<Object?> get props => [vendors];
}

/// Error state
class VendorError extends VendorState {
  final String message;

  const VendorError(this.message);

  @override
  List<Object?> get props => [message];
}
