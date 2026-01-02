import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';
import '../../../core/services/database_service.dart';

// States
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  const OrderLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class OrderCubit extends Cubit<OrderState> {
  final DatabaseService _databaseService;
  StreamSubscription? _ordersSubscription;

  OrderCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(OrderInitial());

  void loadOrders() {
    emit(OrderLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _databaseService.streamOrders().listen(
      (orders) {
        emit(OrderLoaded(orders));
      },
      onError: (error) {
        emit(OrderError(error.toString()));
      },
    );
  }

  Future<void> addOrder(Order order) async {
    final currentState = state;

    // Auto-fire starters and drinks for new items
    final processedItems = order.items.map((item) {
      if (item.kdsStatus == KdsStatus.pending &&
          (item.course == CourseType.starters ||
              item.course == CourseType.drinks)) {
        return item.copyWith(
          kdsStatus: KdsStatus.fired,
          firedAt: DateTime.now(),
        );
      }
      return item;
    }).toList();

    final orderToSave = order.copyWith(items: processedItems);

    if (currentState is OrderLoaded) {
      // Find an active order to merge into (any order that is not served or cancelled)
      final existingOrderIndex = currentState.orders.indexWhere(
        (o) =>
            o.tableId == orderToSave.tableId &&
            o.status != OrderStatus.served &&
            o.status != OrderStatus.cancelled,
      );

      if (existingOrderIndex != -1) {
        final existingOrder = currentState.orders[existingOrderIndex];
        final mergedItems = [...existingOrder.items, ...orderToSave.items];

        String? combinedNotes;
        if (existingOrder.orderNotes != null &&
            orderToSave.orderNotes != null) {
          combinedNotes =
              '${existingOrder.orderNotes}; ${orderToSave.orderNotes}';
        } else {
          combinedNotes = orderToSave.orderNotes ?? existingOrder.orderNotes;
        }

        final mergedOrder = existingOrder.copyWith(
          items: mergedItems,
          orderNotes: combinedNotes,
          updatedAt: DateTime.now(),
          status: OrderStatus.cooking, // Items added, move to cooking
        );

        await _databaseService.saveOrder(mergedOrder);
      } else {
        await _databaseService.saveOrder(orderToSave);
        await _databaseService.updateTableStatus(
          orderToSave.tableId,
          TableStatus.occupied,
        );
      }
    } else {
      await _databaseService.saveOrder(orderToSave);
      await _databaseService.updateTableStatus(
        orderToSave.tableId,
        TableStatus.occupied,
      );
    }
  }

  /// Fire a specific course to the KDS
  Future<void> fireCourse(String orderId, CourseType course) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);
    final firedAt = DateTime.now();

    final updatedItems = order.items.map((item) {
      if (item.course == course && item.kdsStatus == KdsStatus.pending) {
        return item.copyWith(kdsStatus: KdsStatus.fired, firedAt: firedAt);
      }
      return item;
    }).toList();

    await _databaseService.saveOrder(
      order.copyWith(items: updatedItems, status: OrderStatus.cooking),
    );
  }

  /// Update individual item status in KDS
  Future<void> updateItemKdsStatus(
    String orderId,
    String itemId,
    KdsStatus newStatus,
  ) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);
    final updatedItems = order.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(kdsStatus: newStatus);
      }
      return item;
    }).toList();

    // Determine overall order status
    OrderStatus newOrderStatus = order.status;

    bool allServed = updatedItems.every(
      (i) =>
          i.kdsStatus == KdsStatus.served || i.kdsStatus == KdsStatus.cancelled,
    );
    bool allReady = updatedItems.every(
      (i) =>
          i.kdsStatus == KdsStatus.ready ||
          i.kdsStatus == KdsStatus.served ||
          i.kdsStatus == KdsStatus.cancelled,
    );
    bool anyPreparing = updatedItems.any(
      (i) =>
          i.kdsStatus == KdsStatus.preparing || i.kdsStatus == KdsStatus.fired,
    );

    if (allServed) {
      newOrderStatus = OrderStatus.served;
    } else if (allReady) {
      newOrderStatus = OrderStatus.ready;
    } else if (anyPreparing) {
      newOrderStatus = OrderStatus.cooking;
    }

    await _databaseService.saveOrder(
      order.copyWith(
        items: updatedItems,
        status: newOrderStatus,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    final currentState = state;
    if (currentState is OrderLoaded) {
      currentState.orders.firstWhere((o) => o.id == orderId);
      await _databaseService.updateOrderStatus(orderId, newStatus);

      // Auto table transitions
      if (newStatus == OrderStatus.served) {
        // Still occupied
      } else if (newStatus == OrderStatus.cancelled) {
        // Maybe available if no other orders? For now keep occupied if table link exists
      }
    }
  }

  /// Finalize bill and update table status
  Future<void> generateBill(Order order) async {
    await _databaseService.saveOrder(
      order.copyWith(status: OrderStatus.served),
    ); // Ensure it's marked served
    await _databaseService.updateTableStatus(order.tableId, TableStatus.billed);
  }

  /// Complete payment and move table to cleaning
  Future<void> completePayment(Order order, PaymentMethod method) async {
    await _databaseService.saveOrder(
      order.copyWith(paymentStatus: PaymentStatus.paid, paymentMethod: method),
    );
    await _databaseService.updateTableStatus(
      order.tableId,
      TableStatus.cleaning,
    );
  }

  List<Order> getOrdersForTable(String tableId) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      return currentState.orders
          .where((order) => order.tableId == tableId)
          .toList();
    }
    return [];
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
