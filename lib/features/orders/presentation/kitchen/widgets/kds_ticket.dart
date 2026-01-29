import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'kds_item_row.dart';

class KdsTicket extends StatelessWidget {
  final Order order;

  const KdsTicket({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isRush = order.priority != OrderPriority.normal;
    final Color headerColor = isRush
        ? Colors.red.shade700
        : AppDesign.neutral800;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.tableNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildHeaderAction(context),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm:ss').format(order.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Pax: ${order.paxCount}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ticket Body (Items)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return KdsItemRow(orderId: order.id, item: item);
              },
            ),
          ),

          // Ticket Footer
          if (order.orderNotes != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.yellow.shade50,
              child: Text(
                'Notes: ${order.orderNotes}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context) {
    // Collect item statuses
    bool hasPending = order.items.any((i) => i.kdsStatus == KdsStatus.pending);
    bool hasFired = order.items.any((i) => i.kdsStatus == KdsStatus.fired);
    bool hasPreparing = order.items.any(
      (i) => i.kdsStatus == KdsStatus.preparing,
    );
    bool hasReady = order.items.any((i) => i.kdsStatus == KdsStatus.ready);

    IconData icon = Icons.check_circle_outline;
    String tooltip = 'Complete All Items';
    VoidCallback? action;

    if (hasFired) {
      icon = Icons.play_circle_outline;
      tooltip = 'Start Preparing All Fired Items';
      action = () {
        for (var i in order.items) {
          if (i.kdsStatus == KdsStatus.fired) {
            context.read<OrderCubit>().updateItemKdsStatus(
              order.id,
              i.id,
              KdsStatus.preparing,
            );
          }
        }
      };
    } else if (hasPreparing) {
      icon = Icons.done_all;
      tooltip = 'Mark All Preparing as Ready';
      action = () {
        for (var i in order.items) {
          if (i.kdsStatus == KdsStatus.preparing) {
            context.read<OrderCubit>().updateItemKdsStatus(
              order.id,
              i.id,
              KdsStatus.ready,
            );
          }
        }
      };
    } else if (hasReady) {
      icon = Icons.delivery_dining;
      tooltip = 'Serve All Ready Items';
      action = () {
        for (var i in order.items) {
          if (i.kdsStatus == KdsStatus.ready) {
            context.read<OrderCubit>().updateItemKdsStatus(
              order.id,
              i.id,
              KdsStatus.served,
            );
          }
        }
      };
    } else if (hasPending) {
      icon = Icons.flash_on;
      tooltip = 'Fire All Pending Items';
      action = () {
        final courses = order.items
            .where((i) => i.kdsStatus == KdsStatus.pending)
            .map((i) => i.course)
            .toSet();
        for (var c in courses) {
          context.read<OrderCubit>().fireCourse(order.id, c);
        }
      };
    }

    return IconButton(
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      onPressed: action,
    );
  }
}
