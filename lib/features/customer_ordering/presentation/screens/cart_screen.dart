import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_cubit.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_state.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              context.read<CustomerOrderCubit>().clearCart();
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerOrderCubit, CustomerOrderState>(
        builder: (context, state) {
          if (state.cart.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.cart.length,
                  itemBuilder: (context, index) {
                    final item = state.cart[index];
                    return CartItem(
                      item: item,
                      onRemove: () => context
                          .read<CustomerOrderCubit>()
                          .removeFromCart(item),
                      onQuantityChanged: (quantity) => context
                          .read<CustomerOrderCubit>()
                          .updateCartItem(index, quantity, item.notes),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total: ₹${state.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    PremiumButton(
                      label: 'Place Order',
                      onPressed: () {
                        context.read<CustomerOrderCubit>().placeOrder();
                      },
                      isLoading: state.status == CustomerOrderStatus.submitting,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
