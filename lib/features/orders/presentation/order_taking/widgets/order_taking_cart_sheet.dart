import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_cart_item.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/billing/ui/billing_screen.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';

class OrderTakingCartSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<OrderItem> cart;
  final TextEditingController orderNotesController;
  final double totalAmount;
  final String orderType;
  final String? selectedTableId;
  final String? selectedRoom;
  final int paxCount;
  final Customer? selectedCustomer;
  final VoidCallback onPlaceOrder;
  final Function(int) onEditItem;
  final Function(OrderItem) onRemoveItem;

  const OrderTakingCartSheet({
    super.key,
    required this.scrollController,
    required this.cart,
    required this.orderNotesController,
    required this.totalAmount,
    required this.orderType,
    this.selectedTableId,
    this.selectedRoom,
    required this.paxCount,
    this.selectedCustomer,
    required this.onPlaceOrder,
    required this.onEditItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Edit button for whole order (waiter can add more items)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add More Items'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppDesign.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Order',
                  style: AppDesign.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Order'),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items List & Notes Section
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Order Notes (Optional)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2,
                            size: 18,
                            color: AppDesign.neutral600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Order Notes (Optional)',
                            style: AppDesign.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppDesign.neutral700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: orderNotesController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Spicy, No Onions, Extra Napkins',
                          hintStyle: AppDesign.bodyMedium.copyWith(
                            color: AppDesign.neutral400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppDesign.neutral200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppDesign.neutral200),
                          ),
                          filled: true,
                          fillColor: AppDesign.neutral50,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 2,
                        style: AppDesign.bodyMedium,
                      ),
                    ],
                  ),
                ),

                Text(
                  'Order Items',
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppDesign.neutral800,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(cart.length, (index) {
                  final item = cart[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => onRemoveItem(item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete, color: Colors.red.shade700),
                      ),
                      child: OrderCartItem(
                        item: item,
                        canEdit: true,
                        onEdit: () => onEditItem(index),
                        onRemove: () => onRemoveItem(item),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 100), // Extra space for footer
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppDesign.titleLarge),
                      Text(
                        '₹$totalAmount',
                        style: AppDesign.headlineSmall.copyWith(
                          color: AppDesign.primaryStart,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (selectedTableId != null || selectedRoom != null)
                    BlocBuilder<OrderCubit, OrderState>(
                      builder: (context, state) {
                        if (state is OrderLoaded) {
                          final tableId = orderType == 'Table'
                              ? selectedTableId!
                              : 'room_$selectedRoom';
                          final existingOrders = state.orders
                              .where(
                                (o) =>
                                    o.tableId == tableId &&
                                    o.paymentStatus != PaymentStatus.paid,
                              )
                              .toList();

                          if (existingOrders.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PremiumButton.secondary(
                                label: 'Review & Generate Bill',
                                isFullWidth: true,
                                onPressed: () {
                                  String tableNumber = orderType == 'Table'
                                      ? 'Table $selectedTableId'
                                      : 'Room $selectedRoom';
                                  context.push(
                                    '${BillingScreen.routeName}?tableId=$tableId&tableNumber=$tableNumber',
                                    extra: existingOrders,
                                  );
                                },
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  PremiumButton.primary(
                    label: 'Place Order',
                    isFullWidth: true,
                    onPressed: onPlaceOrder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
