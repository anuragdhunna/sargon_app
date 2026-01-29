import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit({String? initialBookingId})
    : super(OrderHistoryState(initialBookingId: initialBookingId));

  void updateFilters({
    bool? showOnlyUnpaid,
    String? selectedStatus,
    String? selectedTableId,
    String? customerQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<Order>? allOrders,
  }) {
    final newState = state.copyWith(
      showOnlyUnpaid: showOnlyUnpaid,
      selectedStatus: selectedStatus,
      selectedTableId: selectedTableId,
      customerQuery: customerQuery,
      startDate: startDate,
      endDate: endDate,
    );

    if (allOrders != null) {
      applyFilters(allOrders, newState);
    } else {
      emit(newState);
    }
  }

  void clearDateRange(List<Order> allOrders) {
    final newState = state.copyWith(startDate: null, endDate: null);
    applyFilters(allOrders, newState);
  }

  void applyFilters(List<Order> allOrders, [OrderHistoryState? currentState]) {
    final s = currentState ?? state;

    final filtered = allOrders.where((o) {
      final matchesUnpaid =
          !s.showOnlyUnpaid || o.paymentStatus != PaymentStatus.paid;
      final matchesStatus =
          s.selectedStatus == null || o.status.name == s.selectedStatus;
      final matchesTable =
          s.selectedTableId == null || o.tableId == s.selectedTableId;
      final matchesCustomer =
          s.customerQuery.isEmpty ||
          (o.guestName?.toLowerCase().contains(s.customerQuery.toLowerCase()) ??
              false) ||
          (o.phone?.contains(s.customerQuery) ?? false);
      final matchesDate =
          (s.startDate == null || o.timestamp.isAfter(s.startDate!)) &&
          (s.endDate == null ||
              o.timestamp.isBefore(s.endDate!.add(const Duration(days: 1))));
      final matchesBooking =
          s.initialBookingId == null || o.bookingId == s.initialBookingId;

      return matchesUnpaid &&
          matchesStatus &&
          matchesTable &&
          matchesCustomer &&
          matchesDate &&
          matchesBooking;
    }).toList();

    emit(s.copyWith(filteredOrders: filtered));
  }
}
