part of '../database_service.dart';

extension DatabaseOrders on DatabaseService {
  DatabaseReference get ordersRef => _ref('orders');

  /// Get all orders (one-time fetch)
  Future<List<Order>> getOrders() async {
    final snapshot = await ordersRef.get();
    if (snapshot.value == null) return <Order>[];

    final dynamic value = snapshot.value;
    Map<dynamic, dynamic> data;

    if (value is Map) {
      data = value;
    } else if (value is List) {
      data = value.asMap();
    } else {
      return <Order>[];
    }

    return data.entries
        .where((e) => e.value != null)
        .map((e) {
          try {
            final orderData = _toMap(e.value);
            return Order.fromJson(orderData);
          } catch (e) {
            debugPrint('Error parsing order: $e');
            return null;
          }
        })
        .whereType<Order>()
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Stream<List<Order>> streamOrders() {
    return ordersRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <Order>[];

        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <Order>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final orderData = _toMap(e.value);
                return Order.fromJson(orderData);
              } catch (e) {
                debugPrint('Error parsing order: $e');
                return null;
              }
            })
            .whereType<Order>()
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        debugPrint('Error in streamOrders: $e');
        return <Order>[];
      }
    });
  }

  /// Stream orders by status (real-time)
  Stream<List<Order>> streamOrdersByStatus(OrderStatus status) {
    return streamOrders().map(
      (orders) => orders.where((o) => o.status == status).toList(),
    );
  }

  /// Stream orders for a specific table (real-time)
  Stream<List<Order>> streamOrdersByTable(String tableId) {
    return streamOrders().map(
      (orders) => orders.where((o) => o.tableId == tableId).toList(),
    );
  }

  /// Save order
  Future<void> saveOrder(Order order) async {
    await ordersRef.child(order.id).set(order.toJson());
  }

  /// Get specific orders by ID list
  Future<List<Order>> getOrdersByIds(List<String> ids) async {
    final futures = ids.map((id) => ordersRef.child(id).get());
    final snapshots = await Future.wait(futures);
    return snapshots
        .where((s) => s.exists && s.value != null)
        .map((s) => Order.fromJson(_toMap(s.value)))
        .toList();
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await ordersRef.child(orderId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Update order payment status
  Future<void> updateOrderPaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {
    await ordersRef.child(orderId).update({
      'paymentStatus': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Initialize dummy orders if none exist
  Future<void> initializeDummyOrders() async {
    try {
      final snapshot = await ordersRef.get();
      if (snapshot.value != null) return;

      final orders = [
        Order(
          id: 'order_1',
          tableId: 't1',
          tableNumber: 'T1',
          status: OrderStatus.ready,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          paxCount: 2,
          priority: OrderPriority.normal,
          items: [
            OrderItem(
              id: 'item_1',
              menuItemId: 'pizza_1',
              name: 'Margherita Pizza',
              price: 350,
              quantity: 1,
              course: CourseType.mains,
              kdsStatus: KdsStatus.ready,
              firedAt: DateTime.now().subtract(const Duration(minutes: 25)),
            ),
            OrderItem(
              id: 'item_2',
              menuItemId: 'coke_1',
              name: 'Coca Cola',
              price: 50,
              quantity: 2,
              course: CourseType.drinks,
              kdsStatus: KdsStatus.served,
              firedAt: DateTime.now().subtract(const Duration(minutes: 28)),
            ),
          ],
          orderNotes: 'No onions please',
        ),
        Order(
          id: 'order_2',
          tableId: 't2',
          tableNumber: 'T2',
          status: OrderStatus.cooking,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          paxCount: 4,
          priority: OrderPriority.vip,
          items: [
            OrderItem(
              id: 'item_3',
              menuItemId: 'burger_1',
              name: 'Chicken Burj Burger',
              price: 450,
              quantity: 2,
              course: CourseType.mains,
              kdsStatus: KdsStatus.preparing,
              firedAt: DateTime.now().subtract(const Duration(minutes: 10)),
            ),
          ],
        ),
      ];

      for (final order in orders) {
        await saveOrder(order);
      }
    } catch (e) {
      debugPrint('Error initializing dummy orders: $e');
    }
  }
}
