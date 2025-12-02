import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';

enum OrderStatus { pending, cooking, ready, served }

class Order extends Equatable {
  final String id;
  final String tableNumber;
  final List<MenuItem> items;
  final OrderStatus status;
  final DateTime timestamp;

  const Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.status,
    required this.timestamp,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      tableNumber: tableNumber,
      items: items,
      status: status ?? this.status,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [id, tableNumber, items, status, timestamp];
}
