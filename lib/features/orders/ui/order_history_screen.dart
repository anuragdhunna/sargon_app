import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/features/orders/data/order_model.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_cart_item.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';

/// Order History Screen showing all orders with their current status from KDS
class OrderHistoryScreen extends StatelessWidget {
  static const String routeName = '/order-history';

  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppDesign.headlineSmall.copyWith(
          color: AppDesign.neutral900,
        ),
        iconTheme: const IconThemeData(color: AppDesign.neutral900),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: AppDesign.neutral300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: AppDesign.headlineSmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Sort orders by timestamp (newest first)
            final sortedOrders = List<Order>.from(state.orders)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = sortedOrders[index];
                return _OrderHistoryCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.tableNumber,
                      style: AppDesign.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(order.timestamp),
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral600,
                      ),
                    ),
                  ],
                ),
                _StatusChip(status: order.status),
              ],
            ),
          ),

          // Order Notes (if exists)
          if (order.orderNotes != null && order.orderNotes!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppDesign.warning.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: AppDesign.neutral200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2, size: 16, color: AppDesign.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderNotes!,
                      style: AppDesign.bodyMedium.copyWith(
                        color: AppDesign.neutral800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Items List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items (${order.items.length})',
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OrderCartItem(
                      item: item,
                      canEdit: false,
                      onEdit: () {},
                      onRemove: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppDesign.neutral50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${order.items.fold<double>(0, (sum, item) => sum + item.price).toStringAsFixed(0)}',
                  style: AppDesign.headlineSmall.copyWith(
                    color: AppDesign.primaryStart,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cooking:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return AppDesign.neutral500;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: AppDesign.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cooking:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return AppDesign.neutral600;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.cooking:
        return Icons.soup_kitchen;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.served:
        return Icons.done_all;
    }
  }

  String _getLabel() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cooking:
        return 'Cooking';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
    }
  }
}
