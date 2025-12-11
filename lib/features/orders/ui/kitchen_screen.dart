import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/orders/data/order_model.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:intl/intl.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  static const String routeName = '/kitchen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Display System (KDS)')),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text('No active orders. Kitchen is quiet! 👨‍🍳'),
              );
            }

            // Sort by time (oldest first)
            final orders = List<Order>.from(state.orders)
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.cooking:
        statusColor = Colors.blue;
        break;
      case OrderStatus.ready:
        statusColor = Colors.green;
        break;
      case OrderStatus.served:
        statusColor = Colors.grey;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table ${order.tableNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(order.timestamp),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Text(
                              'Note: ${item.notes}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        order.status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: statusColor.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                    Row(
                      children: [
                        if (order.status == OrderStatus.pending)
                          FilledButton(
                            onPressed: () => context
                                .read<OrderCubit>()
                                .updateStatus(order.id, OrderStatus.cooking),
                            child: const Text('Start Cooking'),
                          ),
                        if (order.status == OrderStatus.cooking)
                          FilledButton(
                            onPressed: () => context
                                .read<OrderCubit>()
                                .updateStatus(order.id, OrderStatus.ready),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Mark Ready'),
                          ),
                        if (order.status == OrderStatus.ready)
                          OutlinedButton(
                            onPressed: () => context
                                .read<OrderCubit>()
                                .updateStatus(order.id, OrderStatus.served),
                            child: const Text('Served'),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
