import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';

class OrderHistoryState extends Equatable {
  final bool showOnlyUnpaid;
  final String? selectedStatus;
  final String? selectedTableId;
  final String customerQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? initialBookingId;
  final List<Order> filteredOrders;

  const OrderHistoryState({
    this.showOnlyUnpaid = false,
    this.selectedStatus,
    this.selectedTableId,
    this.customerQuery = '',
    this.startDate,
    this.endDate,
    this.initialBookingId,
    this.filteredOrders = const [],
  });

  OrderHistoryState copyWith({
    bool? showOnlyUnpaid,
    String? selectedStatus,
    String? selectedTableId,
    String? customerQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? initialBookingId,
    List<Order>? filteredOrders,
  }) {
    return OrderHistoryState(
      showOnlyUnpaid: showOnlyUnpaid ?? this.showOnlyUnpaid,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      customerQuery: customerQuery ?? this.customerQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      initialBookingId: initialBookingId ?? this.initialBookingId,
      filteredOrders: filteredOrders ?? this.filteredOrders,
    );
  }

  @override
  List<Object?> get props => [
    showOnlyUnpaid,
    selectedStatus,
    selectedTableId,
    customerQuery,
    startDate,
    endDate,
    initialBookingId,
    filteredOrders,
  ];
}
