import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/feedback/custom_snackbar.dart';
import 'package:hotel_manager/core/services/pdf_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/apply_offer_dialog.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_detail_dialog.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/payment_dialog.dart';
import 'package:hotel_manager/features/billing/ui/widgets/customer_details_dialog.dart';

import '../cubit/order_history_cubit.dart';
import '../cubit/order_history_state.dart';
import '../widgets/order_history_filter_bar.dart';
import '../widgets/order_history_card.dart';

class OrderHistoryScreen extends StatelessWidget {
  static const String routeName = '/order-history';
  final String? initialBookingId;

  const OrderHistoryScreen({super.key, this.initialBookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = OrderHistoryCubit(initialBookingId: initialBookingId);
        final orderCubit = context.read<OrderCubit>();
        final billingCubit = context.read<BillingCubit>();

        // Ensure data is loaded
        if (orderCubit.state is OrderInitial ||
            orderCubit.state is OrderError) {
          orderCubit.loadOrders();
        } else if (orderCubit.state is OrderLoaded) {
          cubit.applyFilters((orderCubit.state as OrderLoaded).orders);
        }

        if (billingCubit.state is BillingInitial) {
          billingCubit.loadBillingData();
        }

        return cubit;
      },
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderLoaded) {
            context.read<OrderHistoryCubit>().applyFilters(state.orders);
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            final allOrders = orderState is OrderLoaded
                ? orderState.orders
                : <Order>[];

            return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
              builder: (context, historyState) {
                final cubit = context.read<OrderHistoryCubit>();

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
                        icon: const Icon(
                          Icons.info_outline,
                          color: AppDesign.primaryStart,
                        ),
                        onPressed: () => _showStatusGuide(context),
                        tooltip: 'How to use Order History',
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      OrderHistoryFilterBar(
                        customerQuery: historyState.customerQuery,
                        selectedStatus: historyState.selectedStatus,
                        showOnlyUnpaid: historyState.showOnlyUnpaid,
                        startDate: historyState.startDate,
                        endDate: historyState.endDate,
                        onSearchChanged: (q) => cubit.updateFilters(
                          customerQuery: q,
                          allOrders: allOrders,
                        ),
                        onStatusChanged: (s) => cubit.updateFilters(
                          selectedStatus: s,
                          allOrders: allOrders,
                        ),
                        onUnpaidToggle: (u) => cubit.updateFilters(
                          showOnlyUnpaid: u,
                          allOrders: allOrders,
                        ),
                        onSelectDateRange: () =>
                            _selectDateRange(context, cubit, allOrders),
                        onClearDateRange: () => cubit.clearDateRange(allOrders),
                      ),
                      Expanded(
                        child: _buildOrderList(
                          context,
                          orderState,
                          historyState,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    OrderState orderState,
    OrderHistoryState historyState,
  ) {
    if (orderState is OrderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState is OrderLoaded) {
      final orders = historyState.filteredOrders;

      if (orders.isEmpty) {
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
                historyState.showOnlyUnpaid
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

      return BlocBuilder<BillingCubit, BillingState>(
        builder: (context, billingState) {
          final taxRules = billingState is BillingLoaded
              ? billingState.taxRules
              : <TaxRule>[];
          final scRules = billingState is BillingLoaded
              ? billingState.serviceChargeRules
              : <ServiceChargeRule>[];
          final offers = billingState is BillingLoaded
              ? billingState.offers
              : <Offer>[];
          final bills = billingState is BillingLoaded
              ? billingState.bills
              : <Bill>[];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final bill = bills.cast<Bill?>().firstWhere(
                (b) => b!.orderIds.contains(order.id),
                orElse: () => null,
              );

              return OrderHistoryCard(
                order: order,
                bill: bill,
                taxRules: taxRules,
                serviceChargeRules: scRules,
                allOffers: offers,
                onPrintBill: () => _printBill(context, order),
                onRemoveItem: (itemId) => _removeItem(context, order, itemId),
                onApplyOffer: () => _showApplyOfferDialog(context, order),
                onRemoveOffer: () => _removeOffer(context, order),
                onViewDetails: () => _showDetails(context, order, bill),
                onGenerateBill: () => _generateBill(context, order),
                onAddPayment: () => _showPaymentDialog(context, bill!),
                onCancelOrder: () => _cancelOrder(context, order),
              );
            },
          );
        },
      );
    }

    if (orderState is OrderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${orderState.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<OrderCubit>().loadOrders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // --- UI Helpers / Dialogs ---

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
            _buildGuideItem('Pending', 'Order added, not yet cooking.'),
            _buildGuideItem('Cooking', 'Currently being prepared.'),
            _buildGuideItem('Ready', 'Ready to be served to guest.'),
            _buildGuideItem('Served', 'Order reached the table.'),
            const Divider(),
            _buildGuideItem(
              'Generate Bill',
              'Calculate taxes & service charge.',
            ),
            _buildGuideItem(
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

  Widget _buildGuideItem(String title, String desc) {
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

  Future<void> _selectDateRange(
    BuildContext context,
    OrderHistoryCubit cubit,
    List<Order> allOrders,
  ) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          cubit.state.startDate != null && cubit.state.endDate != null
          ? DateTimeRange(
              start: cubit.state.startDate!,
              end: cubit.state.endDate!,
            )
          : null,
    );
    if (range != null) {
      cubit.updateFilters(
        startDate: range.start,
        endDate: range.end,
        allOrders: allOrders,
      );
    }
  }

  void _printBill(BuildContext context, Order order) {
    final billingState = context.read<BillingCubit>().state;
    if (billingState is BillingLoaded) {
      final bill = billingState.bills.firstWhere(
        (b) => b.orderIds.contains(order.id),
        orElse: () => null as dynamic,
      );
      PdfService.generateOrderBill(order, bill);
    } else {
      PdfService.generateOrderBill(order, null);
    }
  }

  void _removeItem(BuildContext context, Order order, String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<OrderCubit>().removeItemFromOrder(order.id, itemId);
      if (context.mounted) CustomSnackbar.showSuccess(context, 'Item removed');
    }
  }

  void _showApplyOfferDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => ApplyOfferDialog(
        orderId: order.id,
        onApply: (offer) {
          context.read<OrderCubit>().applyOfferToOrder(order.id, offer);
          CustomSnackbar.showSuccess(context, 'Offer "${offer.name}" applied!');
        },
      ),
    );
  }

  void _removeOffer(BuildContext context, Order order) {
    context.read<OrderCubit>().removeOfferFromOrder(order.id);
    CustomSnackbar.showSuccess(context, 'Offer removed!');
  }

  void _showDetails(BuildContext context, Order order, Bill? bill) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailDialog(order: order, bill: bill),
    );
  }

  void _cancelOrder(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<OrderCubit>().cancelOrder(order.id);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Order cancelled');
      }
    }
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

  Future<void> _generateBill(BuildContext context, Order order) async {
    final billingState = context.read<BillingCubit>().state;
    if (billingState is! BillingLoaded || billingState.taxRules.isEmpty) {
      CustomSnackbar.showWarning(context, 'Billing rules not loaded.');
      return;
    }

    String? finalCustomerId = order.customerId;
    Customer? linkedCustomer;

    if (order.bookingId != null && order.customerId == null) {
      try {
        final dbService = context.read<DatabaseService>();
        final booking = await dbService.getBookingById(order.bookingId!);
        if (booking?.customerId != null) {
          finalCustomerId = booking!.customerId;
        }
      } catch (e) {
        debugPrint('Error fetching booking: $e');
      }
    } else if (order.customerId == null) {
      await showDialog(
        context: context,
        builder: (context) => CustomerDetailsDialog(
          onConfirm: (customer) {
            linkedCustomer = customer;
          },
        ),
      );
      finalCustomerId = linkedCustomer?.id;
    }

    if (!context.mounted) return;

    try {
      await context.read<BillingCubit>().createBill(
        tableId: order.tableId,
        orders: [order],
        taxRuleId: billingState.taxRules.first.id,
        serviceChargeRuleId: billingState.serviceChargeRules.isNotEmpty
            ? billingState.serviceChargeRules.first.id
            : null,
        roomId: order.roomId,
        bookingId: order.bookingId,
        customerId: finalCustomerId,
      );
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Bill generated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Error generating bill: $e');
      }
    }
  }
}
