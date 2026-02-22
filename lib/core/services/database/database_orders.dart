part of '../database_service.dart';

extension DatabaseOrders on DatabaseService {
  CollectionReference _ordersRef(String hotelId) =>
      _hotelDoc(hotelId).collection('orders');

  /// Stream active orders for a hotel
  Stream<List<Order>> streamOrders(String hotelId) {
    return _ordersRef(hotelId)
        .where(
          'status',
          whereNotIn: [OrderStatus.cancelled.name, OrderStatus.served.name],
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Order.fromJson(data);
          }).toList();
        });
  }

  /// Stream all orders for history
  Stream<List<Order>> streamAllOrders(String hotelId) {
    return _ordersRef(
      hotelId,
    ).orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Order.fromJson(data);
      }).toList();
    });
  }

  /// Get all orders for a hotel (one-time)
  Future<List<Order>> getOrders(String hotelId) async {
    final snapshot = await _ordersRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Order.fromJson(data);
    }).toList();
  }

  /// Get order by ID
  Future<Order?> getOrderById(String hotelId, String orderId) async {
    final doc = await _ordersRef(hotelId).doc(orderId).get();
    if (!doc.exists) return null;
    return Order.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Save or Update Order
  Future<void> saveOrder(Order order) async {
    await _ordersRef(order.hotelId).doc(order.id).set(order.toJson());
  }

  /// Update order status
  Future<void> updateOrderStatus(
    String hotelId,
    String orderId,
    OrderStatus status,
  ) async {
    await _ordersRef(hotelId).doc(orderId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Update order payment status
  Future<void> updateOrderPaymentStatus(
    String hotelId,
    String orderId,
    PaymentStatus status,
  ) async {
    await _ordersRef(hotelId).doc(orderId).update({
      'paymentStatus': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get orders by IDs
  Future<List<Order>> getOrdersByIds(
    String hotelId,
    List<String> orderIds,
  ) async {
    if (orderIds.isEmpty) return [];

    // Firestore supports 'in' query for up to 30 IDs
    final List<Order> orders = [];
    final chunks = <List<String>>[];
    for (var i = 0; i < orderIds.length; i += 30) {
      chunks.add(
        orderIds.sublist(
          i,
          i + 30 > orderIds.length ? orderIds.length : i + 30,
        ),
      );
    }

    for (final chunk in chunks) {
      final snapshot = await _ordersRef(
        hotelId,
      ).where(FieldPath.documentId, whereIn: chunk).get();
      orders.addAll(
        snapshot.docs.map(
          (doc) => Order.fromJson(doc.data() as Map<String, dynamic>),
        ),
      );
    }
    return orders;
  }
}
