import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import '../widgets/kds_ticket.dart';
import '../widgets/kds_legend.dart';

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
          const KdsLegend(),
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
                        color: AppDesign.neutral50,
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
                    return KdsTicket(order: activeOrders[index]);
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
