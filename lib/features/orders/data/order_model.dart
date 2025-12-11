import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';

enum OrderStatus { pending, cooking, ready, served }

class Order extends Equatable {
  final String id;
  final String tableNumber;
  final List<MenuItem> items;
  final OrderStatus status;
  final DateTime timestamp;
  final String?
  orderNotes; // Overall order notes (e.g., "Birthday celebration", "Rush order")

  const Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.status,
    required this.timestamp,
    this.orderNotes,
  });

  Order copyWith({
    String? id,
    String? tableNumber,
    List<MenuItem>? items,
    OrderStatus? status,
    DateTime? timestamp,
    String? orderNotes,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tableNumber,
    items,
    status,
    timestamp,
    orderNotes,
  ];
}
