import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:intl/intl.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  static const String routeName = '/kitchen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral100,
      appBar: AppBar(
        title: const Text('Kitchen Display System (KDS)'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: AppDesign.headlineSmall.copyWith(
          color: AppDesign.neutral900,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppDesign.neutral700),
            onPressed: () => _showKdsInfo(context),
          ),
          _buildKdsLegend(),
        ],
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderLoaded) {
            final activeOrders = state.orders
                .where(
                  (o) =>
                      o.status != OrderStatus.cancelled &&
                      o.status != OrderStatus.served,
                )
                .toList();

            // Sort by priority (VIP/Rush first) then by oldest timestamp
            activeOrders.sort((a, b) {
              if (a.priority != b.priority) {
                return b.priority.index.compareTo(a.priority.index);
              }
              return a.timestamp.compareTo(b.timestamp);
            });

            if (activeOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 64,
                      color: AppDesign.neutral300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active kitchen orders.',
                      style: AppDesign.bodyLarge.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 3
                    : (constraints.maxWidth > 800 ? 2 : 1);

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.95, // Better height for tickets
                  ),
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    return _KdsTicket(order: activeOrders[index]);
                  },
                );
              },
            );
          }
          if (state is OrderError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildKdsLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          _LegendItem(color: Colors.red, label: 'VIP/Rush'),
          _LegendItem(color: Colors.orange, label: 'Delayed'),
          _LegendItem(color: Colors.blue, label: 'Preparing'),
          _LegendItem(color: Colors.green, label: 'Ready'),
        ],
      ),
    );
  }

  void _showKdsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KDS System Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• FIRE: Start cooking items in a course.'),
            Text('• PREP: Item is being prepared by the chef.'),
            Text('• READY: Item is cooked and waiting to be served.'),
            Text('• SERVE: Item has been delivered to the customer.'),
            SizedBox(height: 12),
            Text('Orders are sorted by Priority (VIP first) then by Time.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _KdsTicket extends StatelessWidget {
  final Order order;
  const _KdsTicket({required this.order});

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
                return _KdsItemRow(orderId: order.id, item: item);
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

class _KdsItemRow extends StatelessWidget {
  final String orderId;
  final OrderItem item;
  const _KdsItemRow({required this.orderId, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDelayed = item.isDelayed;
    final bool isCancelled = item.kdsStatus == KdsStatus.cancelled;

    return Opacity(
      opacity: isCancelled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${item.quantity}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                if (isDelayed)
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.orange,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                _buildStatusAction(context),
              ],
            ),
            if (item.notes != null)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  item.notes!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (item.kdsStatus == KdsStatus.fired ||
                item.kdsStatus == KdsStatus.preparing)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: LinearProgressIndicator(
                  value: _calculateProgress(),
                  backgroundColor: AppDesign.neutral100,
                  color: isDelayed ? Colors.orange : Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    if (item.firedAt == null) return 0;
    final elapsed = DateTime.now().difference(item.firedAt!).inMinutes;
    final progress = elapsed / item.expectedPrepTimeMinutes;
    return progress.clamp(0.0, 1.0);
  }

  Widget _buildStatusAction(BuildContext context) {
    if (item.kdsStatus == KdsStatus.cancelled) {
      return const Text(
        'VOID',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
    }
    if (item.kdsStatus == KdsStatus.served) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (item.kdsStatus == KdsStatus.pending) {
      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppDesign.neutral200,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(60, 30),
        ),
        onPressed: () {
          context.read<OrderCubit>().fireCourse(orderId, item.course);
        },
        child: const Text(
          'FIRE',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }

    String label;
    Color color;
    KdsStatus nextStatus;

    switch (item.kdsStatus) {
      case KdsStatus.fired:
        label = 'PREP';
        color = Colors.blue;
        nextStatus = KdsStatus.preparing;
        break;
      case KdsStatus.preparing:
        label = 'READY';
        color = Colors.orange;
        nextStatus = KdsStatus.ready;
        break;
      case KdsStatus.ready:
        label = 'SERVE';
        color = Colors.green;
        nextStatus = KdsStatus.served;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(60, 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: () {
        context.read<OrderCubit>().updateItemKdsStatus(
          orderId,
          item.id,
          nextStatus,
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
