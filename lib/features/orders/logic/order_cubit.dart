import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';
import '../../../core/services/database_service.dart';
import '../../offers/domain/repositories/offer_repository.dart';
import '../../offers/logic/happy_hour_service.dart';
import '../../inventory/logic/stock_manager_service.dart';

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
  final OfferRepository _offerRepository;
  final StockManagerService _stockManagerService;
  StreamSubscription? _ordersSubscription;
  List<HappyHour> _happyHours = [];
  StreamSubscription? _hhSubscription;

  OrderCubit({
    required DatabaseService databaseService,
    required OfferRepository offerRepository,
    required StockManagerService stockManagerService,
  }) : _databaseService = databaseService,
       _offerRepository = offerRepository,
       _stockManagerService = stockManagerService,
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

    _hhSubscription?.cancel();
    _hhSubscription = _offerRepository.watchHappyHours().listen((hh) {
      _happyHours = hh;
    });
  }

  Future<void> addOrder(Order order) async {
    final currentState = state;

    // Auto-fire starters and drinks for new items + Apply Happy Hour
    final processedItems = await Future.wait(
      order.items.map((item) async {
        var updatedItem = item;

        // Happy Hour Check
        if (item.discountAmount == 0 && !item.isComplimentary) {
          final menuItem = await _databaseService.getMenuItem(item.menuItemId);
          if (menuItem != null) {
            final hh = HappyHourService.getActiveHappyHour(
              _happyHours,
              menuItem,
              DateTime.now(),
            );
            updatedItem = HappyHourService.applyHappyHour(updatedItem, hh);
          }
        }

        if (updatedItem.kdsStatus == KdsStatus.pending &&
            (updatedItem.course == CourseType.starters ||
                updatedItem.course == CourseType.drinks)) {
          updatedItem = updatedItem.copyWith(
            kdsStatus: KdsStatus.fired,
            firedAt: Optional(DateTime.now()),
          );
        }
        return updatedItem;
      }),
    );

    final orderToSave = order.copyWith(items: processedItems);

    if (currentState is OrderLoaded) {
      // Find an active order to merge into (any order that is not served or cancelled)
      final existingOrderIndex = currentState.orders.indexWhere(
        (o) =>
            o.tableId == orderToSave.tableId &&
            o.paymentStatus == PaymentStatus.pending &&
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
          orderNotes: Optional(combinedNotes),
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
        return item.copyWith(
          kdsStatus: KdsStatus.fired,
          firedAt: Optional(firedAt),
        );
      }
      return item;
    }).toList();

    await _databaseService.saveOrder(
      order.copyWith(items: updatedItems, status: OrderStatus.cooking),
    );

    // Deduct stock for fired items
    final itemsToDeduct = order.items.where((item) {
      return item.course == course && item.kdsStatus == KdsStatus.pending;
    }).toList();

    if (itemsToDeduct.isNotEmpty) {
      await _stockManagerService.deductStockForItems(itemsToDeduct);
    }
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

  /// Cancel an entire order
  Future<void> cancelOrder(String orderId) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);

    // Mark all items as cancelled
    final cancelledItems = order.items.map((item) {
      return item.copyWith(kdsStatus: KdsStatus.cancelled);
    }).toList();

    await _databaseService.saveOrder(
      order.copyWith(
        items: cancelledItems,
        status: OrderStatus.cancelled,
        updatedAt: DateTime.now(),
      ),
    );

    // If this was the only active order for the table, mark table as available
    final remainingOrders = currentState.orders
        .where(
          (o) =>
              o.tableId == order.tableId &&
              o.id != orderId &&
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.served,
        )
        .toList();

    if (remainingOrders.isEmpty) {
      await _databaseService.updateTableStatus(
        order.tableId,
        TableStatus.available,
      );
    }
  }

  /// Remove a specific item from an order
  Future<void> removeItemFromOrder(String orderId, String itemId) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);

    // Revert stock for the item being removed
    try {
      final removedItem = order.items.firstWhere((item) => item.id == itemId);
      await _stockManagerService.revertStockForItems([removedItem]);
    } catch (_) {
      // Item might not exist or be found, ignore
    }

    // Remove the item from the list
    final updatedItems = order.items
        .where((item) => item.id != itemId)
        .toList();

    // If no items left, cancel the order
    if (updatedItems.isEmpty) {
      await cancelOrder(orderId);
      return;
    }

    // Otherwise save the order with updated items
    await _databaseService.saveOrder(
      order.copyWith(items: updatedItems, updatedAt: DateTime.now()),
    );
  }

  /// Apply An Offer to an entire order
  Future<void> applyOfferToOrder(String orderId, Offer offer) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);

    // Apply offer logic
    final updatedItems = order.items.map((item) {
      double discountAmount = 0.0;

      // Correct base price calculation (including options)
      double itemPriceWithPriv =
          item.price + (item.options?.fold(0.0, (s, o) => s! + o.price) ?? 0.0);
      double totalItemBasePrice = itemPriceWithPriv * item.quantity;

      // Check if offer is applicable to this item
      bool isApplicable = false;
      if (offer.offerType == OfferType.bill) {
        isApplicable = true;
      } else if (offer.offerType == OfferType.item) {
        isApplicable = offer.applicableItemIds.contains(item.menuItemId);
      } else if (offer.offerType == OfferType.category) {
        isApplicable =
            item.categoryId != null &&
            offer.applicableCategoryIds.contains(item.categoryId);
      }

      if (isApplicable) {
        if (offer.discountType == DiscountType.percent) {
          discountAmount = totalItemBasePrice * (offer.discountValue / 100);
        } else {
          discountAmount = offer.discountValue / order.items.length;
        }

        // Cap discount
        if (discountAmount > offer.maxDiscountAmount) {
          discountAmount = offer.maxDiscountAmount;
        }

        return item.copyWith(
          discountAmount: discountAmount,
          discountType: Optional(offer.discountType),
        );
      }
      return item;
    }).toList();

    await _databaseService.saveOrder(
      order.copyWith(
        items: updatedItems,
        appliedOfferId: Optional(offer.id),
        appliedOfferName: Optional(offer.name),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Remove an applied offer from an order
  Future<void> removeOfferFromOrder(String orderId) async {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    final order = currentState.orders.firstWhere((o) => o.id == orderId);

    // Reset all item discounts
    final resetItems = order.items.map((item) {
      return item.copyWith(
        discountAmount: 0.0,
        discountType: const Optional(null),
      );
    }).toList();

    await _databaseService.saveOrder(
      order.copyWith(
        items: resetItems,
        appliedOfferId: const Optional(null),
        appliedOfferName: const Optional(null),
        updatedAt: DateTime.now(),
      ),
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
    _hhSubscription?.cancel();
    return super.close();
  }
}
