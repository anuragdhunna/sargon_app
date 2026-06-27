import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_cubit.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_state.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/widgets/menu_item_card.dart';
import 'cart_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerOrderCubit, CustomerOrderState>(
        builder: (context, state) {
          if (state.status == CustomerOrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CustomerOrderStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.allMenuItems.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search menu',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) => context
                      .read<CustomerOrderCubit>()
                      .updateSearchQuery(query),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: state.selectedCategory == null,
                      onSelected: (_) => context
                          .read<CustomerOrderCubit>()
                          .updateCategory(null),
                    ),
                    const SizedBox(width: 8),
                    ...MenuCategory.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category.name.capitalize()),
                          selected: state.selectedCategory == category,
                          onSelected: (_) => context
                              .read<CustomerOrderCubit>()
                              .updateCategory(category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = state.filteredItems[index];
                    return MenuItemCard(
                      item: item,
                      onAddToCart: (quantity, notes, course) => context
                          .read<CustomerOrderCubit>()
                          .addToCart(item, quantity, notes, course),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
