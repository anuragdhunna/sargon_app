import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_cubit.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_state.dart';
import 'menu_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerOrderCubit, CustomerOrderState>(
      builder: (context, state) {
        if (state.status != CustomerOrderStatus.success ||
            state.placedOrderId == null) {
          // If not success or no order id, go back to menu
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MenuScreen()),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Order Placed')),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Your order has been placed!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order #: ${state.placedOrderId}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PremiumButton(
                  label: 'Order Again',
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MenuScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MenuScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Menu'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
