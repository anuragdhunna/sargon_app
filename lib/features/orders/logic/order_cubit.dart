import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';
import 'package:hotel_manager/features/orders/data/order_model.dart';

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

// Cubit
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial()) {
    // Initialize with some mock data
    emit(
      OrderLoaded([
        Order(
          id: '1',
          tableNumber: '5',
          items: const [
            MenuItem(
              id: '1',
              name: 'Butter Chicken',
              description: '',
              price: 350,
              category: MenuCategory.mainCourse,
              imageUrl: '',
            ),
            MenuItem(
              id: '3',
              name: 'Dal Makhani',
              description: '',
              price: 220,
              category: MenuCategory.mainCourse,
              imageUrl: '',
            ),
          ],
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ]),
    );
  }

  void addOrder(Order order) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      // Check if there's an existing PENDING order for the same table
      final existingOrderIndex = currentState.orders.indexWhere(
        (o) =>
            o.tableNumber == order.tableNumber &&
            o.status == OrderStatus.pending,
      );

      if (existingOrderIndex != -1) {
        // Merge with existing order (industry standard for Indian dining)
        final existingOrder = currentState.orders[existingOrderIndex];
        final mergedItems = [...existingOrder.items, ...order.items];

        // Combine notes if both exist
        String? combinedNotes;
        if (existingOrder.orderNotes != null && order.orderNotes != null) {
          combinedNotes = '${existingOrder.orderNotes}; ${order.orderNotes}';
        } else {
          combinedNotes = order.orderNotes ?? existingOrder.orderNotes;
        }

        final mergedOrder = existingOrder.copyWith(
          items: mergedItems,
          orderNotes: combinedNotes,
          timestamp: DateTime.now(), // Update timestamp to latest
        );

        final updatedOrders = List<Order>.from(currentState.orders);
        updatedOrders[existingOrderIndex] = mergedOrder;
        emit(OrderLoaded(updatedOrders));
      } else {
        // No existing pending order for this table, add as new
        final updatedOrders = List<Order>.from(currentState.orders)..add(order);
        emit(OrderLoaded(updatedOrders));
      }
    } else {
      emit(OrderLoaded([order]));
    }
  }

  void updateStatus(String orderId, OrderStatus newStatus) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      final index = currentState.orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updatedOrders = List<Order>.from(currentState.orders);
        updatedOrders[index] = updatedOrders[index].copyWith(status: newStatus);
        emit(OrderLoaded(updatedOrders));
      }
    }
  }

  List<Order> getOrdersForTable(String tableNumber) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      return currentState.orders
          .where((order) => order.tableNumber == tableNumber)
          .toList();
    }
    return [];
  }
}
