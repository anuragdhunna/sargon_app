import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';

/// Order Detail Dialog showing complete order information
/// - Order items with discounts
/// - Applied offers
/// - Loyalty points earned (once billed)
/// - Tax breakdown
class OrderDetailDialog extends StatelessWidget {
  final Order order;
  final Bill? bill;

  const OrderDetailDialog({super.key, required this.order, this.bill});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = order.items.any((i) => i.discountAmount > 0);
    final totalDiscount = order.items.fold(
      0.0,
      (sum, i) => sum + i.discountAmount,
    );

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: AppDesign.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Table ${order.tableNumber}${order.roomId != null ? ' (Room Service: Room ${order.roomId})' : ''}',
              style: AppDesign.bodyLarge.copyWith(
                color: AppDesign.neutral700,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy hh:mm a').format(order.timestamp),
                  style: AppDesign.bodySmall.copyWith(color: Colors.grey),
                ),
                if (order.guestName != null)
                  Text(
                    'Guest: ${order.guestName}',
                    style: AppDesign.bodySmall.copyWith(
                      color: AppDesign.primaryStart,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            // Customer Info (if linked)
            if (order.guestName != null || order.phone != null) ...[
              Text(
                'Customer Info',
                style: AppDesign.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDesign.neutral500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.guestName ?? 'Walking Guest',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (order.phone != null) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(order.phone!, style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
              const Divider(height: 24),
            ],

            // Order Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items (${order.items.length})',
                      style: AppDesign.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) {
                      final hasItemDiscount = item.discountAmount > 0;
                      final originalPrice = item.price * item.quantity;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity}x ${item.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (item.notes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.notes!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  if (hasItemDiscount)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.discountType == DiscountType.percent ? '${((item.discountAmount / originalPrice) * 100).toStringAsFixed(0)}% ' : ''}Offer Applied',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (hasItemDiscount)
                                  Text(
                                    '₹${originalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasItemDiscount
                                        ? Colors.green
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    if (hasDiscount) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Discount',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '- ₹${totalDiscount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: 24),

                    // Bill Summary (if billed)
                    if (bill != null) ...[
                      Text(
                        'Bill Summary',
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Subtotal', bill!.taxSummary.subTotal),
                      if (bill!.taxSummary.totalDiscountAmount > 0)
                        _buildSummaryRow(
                          'Discount',
                          -bill!.taxSummary.totalDiscountAmount,
                          color: Colors.green,
                        ),
                      if (bill!.taxSummary.serviceChargeAmount > 0)
                        _buildSummaryRow(
                          'Service Charge',
                          bill!.taxSummary.serviceChargeAmount,
                        ),
                      _buildSummaryRow('CGST', bill!.taxSummary.cgstAmount),
                      _buildSummaryRow('SGST', bill!.taxSummary.sgstAmount),
                      const Divider(),
                      _buildSummaryRow(
                        'Grand Total',
                        bill!.taxSummary.grandTotal,
                        isBold: true,
                      ),
                      const SizedBox(height: 16),

                      // Loyalty Points Earned
                      if (bill!.customerId != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.orange),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Loyalty Points Earned',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateLoyaltyPoints(bill!.grandTotal)} points',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateLoyaltyPoints(double billAmount) {
    // Simple calculation: 1 point per ₹100 spent
    // TODO: Fetch from PointRule for actual calculation
    return (billAmount / 100).floor();
  }
}
