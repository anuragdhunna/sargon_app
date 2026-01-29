import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../theme/app_design.dart';

class BillSummaryCard extends StatelessWidget {
  final BillTaxSummary summary;
  final List<BillDiscount> manualDiscounts;
  final bool showServiceCharge;
  final ValueChanged<bool> onServiceChargeChanged;

  const BillSummaryCard({
    super.key,
    required this.summary,
    this.manualDiscounts = const [],
    required this.showServiceCharge,
    required this.onServiceChargeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: AppDesign.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _SummaryRow(label: 'Subtotal', value: summary.subTotal),

          if (summary.totalDiscountAmount > 0)
            _SummaryRow(
              label: 'Total Discount',
              value: -summary.totalDiscountAmount,
              valueColor: Colors.green.shade700,
            ),

          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Charge',
                style: AppDesign.bodyLarge.copyWith(
                  color: AppDesign.neutral700,
                ),
              ),
              Row(
                children: [
                  Text(
                    '₹${summary.serviceChargeAmount.toStringAsFixed(2)}',
                    style: AppDesign.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: showServiceCharge,
                    onChanged: onServiceChargeChanged,
                    activeTrackColor: AppDesign.primaryStart,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          _SummaryRow(label: 'Taxable Amount', value: summary.taxableAmount),

          const Divider(height: 32),

          if (summary.cgstAmount > 0)
            _SummaryRow(label: 'CGST', value: summary.cgstAmount),
          if (summary.sgstAmount > 0)
            _SummaryRow(label: 'SGST', value: summary.sgstAmount),
          if (summary.igstAmount > 0)
            _SummaryRow(label: 'IGST', value: summary.igstAmount),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppDesign.primaryStart.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: AppDesign.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppDesign.neutral900,
                  ),
                ),
                Text(
                  '₹${summary.grandTotal.toStringAsFixed(2)}',
                  style: AppDesign.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppDesign.primaryStart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppDesign.bodyLarge.copyWith(color: AppDesign.neutral600),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: AppDesign.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppDesign.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
