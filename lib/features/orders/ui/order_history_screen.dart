import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/payment_dialog.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:hotel_manager/component/feedback/custom_snackbar.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:intl/intl.dart';

/// Order History Screen showing all orders with their current status from KDS
class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order-history';

  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _showOnlyUnpaid = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
    context.read<BillingCubit>().loadBillingData();
  }

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
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppDesign.neutral900),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppDesign.primaryStart),
            onPressed: () => _showStatusGuide(context),
            tooltip: 'How to use Order History',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderLoaded) {
                  final orders = state.orders;
                  final filteredOrders = _showOnlyUnpaid
                      ? orders
                            .where((o) => o.paymentStatus != PaymentStatus.paid)
                            .toList()
                      : orders;

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppDesign.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showOnlyUnpaid
                                ? 'No unpaid orders found'
                                : 'No orders yet',
                            style: AppDesign.bodyLarge.copyWith(
                              color: AppDesign.neutral600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _OrderHistoryCard(order: order);
                    },
                  );
                }

                if (state is OrderError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<OrderCubit>().loadOrders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Show All'),
            selected: !_showOnlyUnpaid,
            onSelected: (selected) {
              setState(() => _showOnlyUnpaid = false);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Unpaid Only'),
            selected: _showOnlyUnpaid,
            onSelected: (selected) {
              setState(() => _showOnlyUnpaid = selected);
            },
            selectedColor: AppDesign.primaryStart.withOpacity(0.1),
            checkmarkColor: AppDesign.primaryStart,
            labelStyle: TextStyle(
              color: _showOnlyUnpaid
                  ? AppDesign.primaryStart
                  : AppDesign.neutral700,
              fontWeight: _showOnlyUnpaid ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order History Guide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Status Indicators:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGuideItem(
              context,
              'Pending',
              'Order added, not yet cooking.',
            ),
            _buildGuideItem(context, 'Cooking', 'Currently being prepared.'),
            _buildGuideItem(context, 'Ready', 'Ready to be served to guest.'),
            _buildGuideItem(context, 'Served', 'Order reached the table.'),
            const Divider(),
            _buildGuideItem(
              context,
              'Generate Bill',
              'Calculate taxes & service charge.',
            ),
            _buildGuideItem(
              context,
              'Add Payment',
              'Record guest payment & close order.',
            ),
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

  Widget _buildGuideItem(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            desc,
            style: TextStyle(color: AppDesign.neutral600, fontSize: 13),
          ),
        ],
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
              color: AppDesign.neutral50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDesign.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table ${order.tableNumber}',
                      style: AppDesign.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('hh:mm a').format(order.timestamp),
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _StatusChip(status: order.status),
                    const SizedBox(width: 8),
                    if (order.paymentStatus == PaymentStatus.paid)
                      const Icon(Icons.check_circle, color: Colors.green)
                    else if (order.paymentStatus == PaymentStatus.billed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'BILLED',
                              style: AppDesign.bodySmall.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Items List & Billing Details
          BlocBuilder<BillingCubit, BillingState>(
            builder: (context, billingState) {
              final isBilled = order.paymentStatus == PaymentStatus.billed;
              final bill = isBilled && billingState is BillingLoaded
                  ? billingState.bills.firstWhere(
                      (b) => b.orderIds.contains(order.id),
                      orElse: () => billingState.bills.isNotEmpty
                          ? billingState.bills.first
                          : null as dynamic, // Fallback (should be improved)
                    )
                  : null;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantity}x ${item.name}'),
                                Text('₹${item.totalPrice.toStringAsFixed(0)}'),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        if (order.paymentStatus == PaymentStatus.billed &&
                            bill != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₹${bill.subTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          if (bill.taxSummary.serviceChargeAmount > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Service Charge',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '₹${bill.taxSummary.serviceChargeAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CGST',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₹${bill.taxSummary.cgstAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'SGST',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₹${bill.taxSummary.sgstAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${(bill?.grandTotal ?? order.totalPrice).toStringAsFixed(2)}',
                              style: AppDesign.titleLarge.copyWith(
                                color: AppDesign.primaryStart,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  if (order.status != OrderStatus.cancelled &&
                      (order.paymentStatus == PaymentStatus.pending ||
                          order.paymentStatus == PaymentStatus.billed))
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: PremiumButton.primary(
                        label: isBilled ? 'Add Payment' : 'Generate Bill',
                        isFullWidth: true,
                        onPressed: () async {
                          if (billingState is! BillingLoaded ||
                              billingState.taxRules.isEmpty) {
                            CustomSnackbar.showWarning(
                              context,
                              'Billing rules not loaded. Please wait...',
                            );
                            return;
                          }

                          if (isBilled) {
                            if (bill != null) {
                              _showPaymentDialog(context, bill);
                            }
                            return;
                          }

                          try {
                            await context.read<BillingCubit>().createBill(
                              tableId: order.tableId,
                              orders: [order],
                              taxRuleId: billingState.taxRules.first.id,
                              serviceChargeRuleId:
                                  billingState.serviceChargeRules.isNotEmpty
                                  ? billingState.serviceChargeRules.first.id
                                  : null,
                              roomId: order.roomId,
                              bookingId: order.bookingId,
                            );
                            if (context.mounted) {
                              CustomSnackbar.showSuccess(
                                context,
                                'Bill generated successfully!',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              CustomSnackbar.showError(
                                context,
                                'Error generating bill: $e',
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<BillingCubit>(),
        child: PaymentDialog(bill: bill),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
        return AppDesign.primaryStart;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
