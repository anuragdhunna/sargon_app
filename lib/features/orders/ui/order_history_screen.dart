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
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/core/services/pdf_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:intl/intl.dart';
import '../presentation/widgets/apply_offer_dialog.dart';
import '../../billing/logic/discount_calculator.dart';
import '../../billing/ui/widgets/customer_details_dialog.dart';
import '../presentation/widgets/order_detail_dialog.dart';

/// Order History Screen showing all orders with their current status from KDS
class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order-history';
  final String? initialBookingId;

  const OrderHistoryScreen({super.key, this.initialBookingId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _showOnlyUnpaid = false;
  String? _selectedStatus;
  String? _selectedTableId;
  String _customerQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _initialBookingId;

  @override
  void initState() {
    super.initState();
    _initialBookingId = widget.initialBookingId;
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
                  final filteredOrders = orders.where((o) {
                    final matchesUnpaid =
                        !_showOnlyUnpaid ||
                        o.paymentStatus != PaymentStatus.paid;
                    final matchesStatus =
                        _selectedStatus == null ||
                        o.status.name == _selectedStatus;
                    final matchesTable =
                        _selectedTableId == null ||
                        o.tableId == _selectedTableId;
                    final matchesCustomer =
                        _customerQuery.isEmpty ||
                        (o.guestName?.toLowerCase().contains(
                              _customerQuery.toLowerCase(),
                            ) ??
                            false) ||
                        (o.phone?.contains(_customerQuery) ?? false);
                    final matchesDate =
                        (_startDate == null ||
                            o.timestamp.isAfter(_startDate!)) &&
                        (_endDate == null ||
                            o.timestamp.isBefore(
                              _endDate!.add(const Duration(days: 1)),
                            ));
                    final matchesBooking =
                        _initialBookingId == null ||
                        o.bookingId == _initialBookingId;

                    return matchesUnpaid &&
                        matchesStatus &&
                        matchesTable &&
                        matchesCustomer &&
                        matchesDate &&
                        matchesBooking;
                  }).toList();

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
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Customer/Phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _customerQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppDesign.primaryStart,
                ),
                onPressed: () => _selectDateRange(context),
              ),
              if (_startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown<String?>(
                  name: 'status',
                  label: 'Status',
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...OrderStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s.name,
                        child: Text(s.displayName),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Unpaid'),
                selected: _showOnlyUnpaid,
                onSelected: (selected) =>
                    setState(() => _showOnlyUnpaid = selected),
                selectedColor: AppDesign.primaryStart.withOpacity(0.1),
                checkmarkColor: AppDesign.primaryStart,
              ),
            ],
          ),
          if (_startDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Date: ${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}',
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.primaryStart,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
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
                    Row(
                      children: [
                        Text(
                          'Table ${order.tableNumber}',
                          style: AppDesign.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (order.roomId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesign.primaryStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Room ${order.roomId!.replaceAll('room_', '')}',
                              style: AppDesign.bodySmall.copyWith(
                                color: AppDesign.primaryStart,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(order.timestamp),
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.neutral500,
                          ),
                        ),
                        if (order.waiterName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${order.waiterName}',
                            style: AppDesign.bodySmall.copyWith(
                              color: AppDesign.neutral600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.print, size: 20),
                      onPressed: () => _printBill(context),
                      tooltip: 'Print Bill',
                    ),
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
              final isBilled =
                  order.paymentStatus == PaymentStatus.billed ||
                  order.paymentStatus == PaymentStatus.paid ||
                  order.paymentStatus == PaymentStatus.partially_paid ||
                  order.paymentStatus == PaymentStatus.toRoom;

              final bill = isBilled && billingState is BillingLoaded
                  ? billingState.bills.firstWhere(
                      (b) => b.orderIds.contains(order.id),
                      orElse: () => billingState.bills.isNotEmpty
                          ? billingState.bills.first
                          : null as dynamic,
                    )
                  : null;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...order.items.asMap().entries.map((entry) {
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.quantity}x ${item.name}'),
                                ),
                                Row(
                                  children: [
                                    if (item.discountAmount > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Text(
                                          '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      '₹${item.totalPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: item.discountAmount > 0
                                            ? Colors.green
                                            : null,
                                        fontWeight: item.discountAmount > 0
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                    if (order.status != OrderStatus.cancelled &&
                                        order.paymentStatus ==
                                            PaymentStatus.pending)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _removeItem(context, item.id),
                                        tooltip: 'Remove item',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        if (order.status != OrderStatus.cancelled &&
                            (order.paymentStatus == PaymentStatus.billed ||
                                order.paymentStatus == PaymentStatus.pending) &&
                            billingState is BillingLoaded) ...[
                          () {
                            final appliedOffer = order.appliedOfferId != null
                                ? billingState.offers.firstWhere(
                                    (o) => o.id == order.appliedOfferId,
                                    orElse: () => null as dynamic,
                                  )
                                : null;

                            final BillTaxSummary displayBill =
                                bill?.taxSummary ??
                                DiscountCalculator.calculateTaxSummary(
                                  orders: [order],
                                  taxRule: billingState.taxRules.isNotEmpty
                                      ? billingState.taxRules.first
                                      : null,
                                  scRule:
                                      billingState.serviceChargeRules.isNotEmpty
                                      ? billingState.serviceChargeRules.first
                                      : null,
                                  manualDiscounts: appliedOffer != null
                                      ? [appliedOffer]
                                      : [],
                                );

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      order.paymentStatus ==
                                              PaymentStatus.pending
                                          ? 'Subtotal (Est.)'
                                          : 'Subtotal',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '₹${displayBill.subTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                if (order.appliedOfferName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Promotion Applied',
                                          style: AppDesign.bodySmall.copyWith(
                                            color: AppDesign.primaryStart,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          order.appliedOfferName!,
                                          style: AppDesign.bodySmall.copyWith(
                                            color: AppDesign.primaryStart,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (displayBill.totalDiscountAmount > 0 ||
                                    order.appliedOfferId != null)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.appliedOfferName != null
                                            ? 'Discount (${order.appliedOfferName})'
                                            : 'Discount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              displayBill.totalDiscountAmount >
                                                  0
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '- ₹${displayBill.totalDiscountAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              displayBill.totalDiscountAmount >
                                                  0
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (displayBill.serviceChargeAmount > 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Service Charge',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '₹${displayBill.serviceChargeAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'CGST',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '₹${displayBill.cgstAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SGST',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '₹${displayBill.sgstAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹${displayBill.grandTotal.toStringAsFixed(2)}',
                                      style: AppDesign.titleLarge.copyWith(
                                        color: AppDesign.primaryStart,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }(),
                        ],
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // View Details is always visible
                        PremiumButton.outline(
                          label: 'View Details',
                          icon: Icons.info_outline,
                          isFullWidth: true,
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) =>
                                OrderDetailDialog(order: order, bill: bill),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Management Actions (only for non-cancelled & non-paid)
                        if (order.status != OrderStatus.cancelled &&
                            (order.paymentStatus == PaymentStatus.pending ||
                                order.paymentStatus ==
                                    PaymentStatus.billed)) ...[
                          if (order.paymentStatus == PaymentStatus.pending)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PremiumButton.outline(
                                label: order.appliedOfferId != null
                                    ? 'Change Offer'
                                    : 'Apply Offer',
                                icon: Icons.local_offer,
                                isFullWidth: true,
                                onPressed: () => _showApplyOfferDialog(context),
                              ),
                            ),
                          if (order.paymentStatus == PaymentStatus.pending &&
                              order.appliedOfferId != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PremiumButton.danger(
                                label: 'Remove Offer',
                                icon: Icons.delete_outline,
                                isFullWidth: true,
                                onPressed: () {
                                  context
                                      .read<OrderCubit>()
                                      .removeOfferFromOrder(order.id);
                                  CustomSnackbar.showSuccess(
                                    context,
                                    'Offer removed!',
                                  );
                                },
                              ),
                            ),
                          PremiumButton.primary(
                            label: isBilled ? 'Add Payment' : 'Generate Bill',
                            isFullWidth: true,
                            onPressed:
                                (isBilled || order.status == OrderStatus.served)
                                ? () async {
                                    if (billingState is! BillingLoaded ||
                                        billingState.taxRules.isEmpty) {
                                      CustomSnackbar.showWarning(
                                        context,
                                        'Billing rules not loaded.',
                                      );
                                      return;
                                    }
                                    if (isBilled) {
                                      if (bill != null)
                                        _showPaymentDialog(context, bill);
                                      return;
                                    }

                                    // Step 1: Link Customer for Loyalty
                                    String? finalCustomerId = order.customerId;
                                    Customer? linkedCustomer;

                                    if (order.bookingId != null &&
                                        order.customerId == null) {
                                      // Room service order - fetch customer from booking
                                      debugPrint(
                                        'Room Service Order detected: ${order.bookingId}',
                                      );
                                      try {
                                        final dbService = context
                                            .read<DatabaseService>();
                                        final booking = await dbService
                                            .getBookingById(order.bookingId!);
                                        debugPrint(
                                          'Fetched booking: ${booking?.guestName}, CustomerId: ${booking?.customerId}',
                                        );
                                        if (booking?.customerId != null) {
                                          finalCustomerId = booking!.customerId;
                                        }
                                      } catch (e) {
                                        debugPrint(
                                          'Error fetching booking: $e',
                                        );
                                      }
                                    } else if (order.customerId == null) {
                                      // Regular order - ask for details
                                      debugPrint(
                                        'Regular Order detected, asking for details',
                                      );
                                      await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            CustomerDetailsDialog(
                                              onConfirm: (customer) {
                                                linkedCustomer = customer;
                                              },
                                            ),
                                      );
                                      finalCustomerId = linkedCustomer?.id;
                                    }

                                    try {
                                      await context
                                          .read<BillingCubit>()
                                          .createBill(
                                            tableId: order.tableId,
                                            orders: [order],
                                            taxRuleId:
                                                billingState.taxRules.first.id,
                                            serviceChargeRuleId:
                                                billingState
                                                    .serviceChargeRules
                                                    .isNotEmpty
                                                ? billingState
                                                      .serviceChargeRules
                                                      .first
                                                      .id
                                                : null,
                                            roomId: order.roomId,
                                            bookingId: order.bookingId,
                                            customerId: finalCustomerId,
                                          );
                                      if (context.mounted)
                                        CustomSnackbar.showSuccess(
                                          context,
                                          'Bill generated successfully!',
                                        );
                                    } catch (e) {
                                      if (context.mounted)
                                        CustomSnackbar.showError(
                                          context,
                                          'Error generating bill: $e',
                                        );
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Cancel Order Button
                  if (order.status != OrderStatus.cancelled &&
                      order.paymentStatus == PaymentStatus.pending)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PremiumButton.danger(
                        label: 'Cancel Order',
                        onPressed: () => _cancelOrder(context),
                        isFullWidth: true,
                        icon: Icons.cancel,
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context) async {
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
      if (context.mounted)
        CustomSnackbar.showSuccess(context, 'Order cancelled');
    }
  }

  void _removeItem(BuildContext context, String itemId) async {
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

  void _showApplyOfferDialog(BuildContext context) {
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

  void _printBill(BuildContext context) {
    final billingCubit = context.read<BillingCubit>();
    if (billingCubit.state is BillingLoaded) {
      final billingState = billingCubit.state as BillingLoaded;
      final bill = billingState.bills.firstWhere(
        (b) => b.orderIds.contains(order.id),
        orElse: () => null as dynamic,
      );
      PdfService.generateOrderBill(order, bill);
    } else {
      PdfService.generateOrderBill(order, null);
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
