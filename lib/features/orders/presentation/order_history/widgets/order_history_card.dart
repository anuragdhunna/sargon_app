import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/features/billing/logic/discount_calculator.dart';
import 'order_status_chip.dart';

class OrderHistoryCard extends StatelessWidget {
  final Order order;
  final Bill? bill;
  final List<TaxRule> taxRules;
  final List<ServiceChargeRule> serviceChargeRules;
  final List<Offer> allOffers;
  final VoidCallback onPrintBill;
  final Function(String) onRemoveItem;
  final VoidCallback onApplyOffer;
  final VoidCallback onRemoveOffer;
  final VoidCallback onViewDetails;
  final VoidCallback onGenerateBill;
  final VoidCallback onAddPayment;
  final VoidCallback onCancelOrder;

  const OrderHistoryCard({
    super.key,
    required this.order,
    this.bill,
    required this.taxRules,
    required this.serviceChargeRules,
    required this.allOffers,
    required this.onPrintBill,
    required this.onRemoveItem,
    required this.onApplyOffer,
    required this.onRemoveOffer,
    required this.onViewDetails,
    required this.onGenerateBill,
    required this.onAddPayment,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Items List & Billing Details
          _buildBody(),

          // Action Buttons
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                onPressed: onPrintBill,
                tooltip: 'Print Bill',
              ),
              OrderStatusChip(status: order.status),
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
    );
  }

  Widget _buildBody() {
    final appliedOffer = order.appliedOfferId != null
        ? allOffers.firstWhere(
            (o) => o.id == order.appliedOfferId,
            orElse: () => null as dynamic,
          )
        : null;

    final BillTaxSummary displayBill =
        bill?.taxSummary ??
        DiscountCalculator.calculateTaxSummary(
          orders: [order],
          taxRule: taxRules.isNotEmpty ? taxRules.first : null,
          scRule: serviceChargeRules.isNotEmpty
              ? serviceChargeRules.first
              : null,
          manualDiscounts: appliedOffer != null ? [appliedOffer] : [],
        );

    return Padding(
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
                  Expanded(child: Text('${item.quantity}x ${item.name}')),
                  Row(
                    children: [
                      if (item.discountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: item.discountAmount > 0 ? Colors.green : null,
                          fontWeight: item.discountAmount > 0
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      if (order.status != OrderStatus.cancelled &&
                          order.paymentStatus == PaymentStatus.pending)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () => onRemoveItem(item.id),
                          tooltip: 'Remove item',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          if (order.status != OrderStatus.cancelled &&
              (order.paymentStatus == PaymentStatus.billed ||
                  order.paymentStatus == PaymentStatus.pending))
            _buildBillingSummary(displayBill),
        ],
      ),
    );
  }

  Widget _buildBillingSummary(BillTaxSummary displayBill) {
    return Column(
      children: [
        _buildSummaryRow(
          order.paymentStatus == PaymentStatus.pending
              ? 'Subtotal (Est.)'
              : 'Subtotal',
          '₹${displayBill.subTotal.toStringAsFixed(2)}',
        ),
        if (order.appliedOfferName != null)
          _buildSummaryRow(
            'Promotion Applied',
            order.appliedOfferName!,
            isBold: true,
            color: AppDesign.primaryStart,
          ),
        if (displayBill.totalDiscountAmount > 0 || order.appliedOfferId != null)
          _buildSummaryRow(
            order.appliedOfferName != null
                ? 'Discount (${order.appliedOfferName})'
                : 'Discount',
            '- ₹${displayBill.totalDiscountAmount.toStringAsFixed(2)}',
            isBold: true,
            color: displayBill.totalDiscountAmount > 0
                ? Colors.green
                : Colors.grey,
          ),
        if (displayBill.serviceChargeAmount > 0)
          _buildSummaryRow(
            'Service Charge',
            '₹${displayBill.serviceChargeAmount.toStringAsFixed(2)}',
          ),
        _buildSummaryRow(
          'CGST',
          '₹${displayBill.cgstAmount.toStringAsFixed(2)}',
        ),
        _buildSummaryRow(
          'SGST',
          '₹${displayBill.sgstAmount.toStringAsFixed(2)}',
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grand Total',
              style: TextStyle(fontWeight: FontWeight.bold),
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
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final isBilled =
        order.paymentStatus == PaymentStatus.billed ||
        order.paymentStatus == PaymentStatus.paid ||
        order.paymentStatus == PaymentStatus.partially_paid ||
        order.paymentStatus == PaymentStatus.toRoom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          PremiumButton.outline(
            label: 'View Details',
            icon: Icons.info_outline,
            isFullWidth: true,
            onPressed: onViewDetails,
          ),
          const SizedBox(height: 12),
          if (order.status != OrderStatus.cancelled &&
              (order.paymentStatus == PaymentStatus.pending ||
                  order.paymentStatus == PaymentStatus.billed)) ...[
            if (order.paymentStatus == PaymentStatus.pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumButton.outline(
                  label: order.appliedOfferId != null
                      ? 'Change Offer'
                      : 'Apply Offer',
                  icon: Icons.local_offer,
                  isFullWidth: true,
                  onPressed: onApplyOffer,
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
                  onPressed: onRemoveOffer,
                ),
              ),
            PremiumButton.primary(
              label: isBilled ? 'Add Payment' : 'Generate Bill',
              isFullWidth: true,
              onPressed: (isBilled || order.status == OrderStatus.served)
                  ? (isBilled ? onAddPayment : onGenerateBill)
                  : null,
            ),
          ],
          if (order.status != OrderStatus.cancelled &&
              order.paymentStatus == PaymentStatus.pending)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PremiumButton.danger(
                label: 'Cancel Order',
                onPressed: onCancelOrder,
                isFullWidth: true,
                icon: Icons.cancel,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
