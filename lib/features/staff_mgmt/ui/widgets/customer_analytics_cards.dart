import 'package:flutter/material.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';
import 'customer_detail_dialog.dart';

/// Metric summary card for KPI overview row
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppDesign.bodySmall.copyWith(
                      color: AppDesign.neutral500,
                    ),
                  ),
                  Text(
                    value,
                    style: AppDesign.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subValue != null)
                    Text(
                      subValue!,
                      style: AppDesign.bodySmall.copyWith(color: color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Customer profile card displayed in analytics grid
class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _showCustomerDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppDesign.primaryStart.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppDesign.primaryStart,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (customer.loyaltyInfo != null)
                  _buildLoyaltyBadge(customer.loyaltyInfo!),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  'Total Spent',
                  '₹${NumberFormat('#,##,###').format(customer.totalSpent)}',
                ),
                _buildStat('Bookings', customer.totalBookings.toString()),
                _buildStat(
                  'Points',
                  customer.loyaltyInfo?.availablePoints.toString() ?? '0',
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customer.lastVisit != null
                      ? 'Last: ${DateFormat('MMM dd, yyyy').format(customer.lastVisit!)}'
                      : 'Never visited',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral400,
                  ),
                ),
                TextButton(
                  onPressed: () => _showCustomerDetails(context),
                  child: const Text('View History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyBadge(LoyaltyInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Text(
        info.tierId.split('_').last.toUpperCase(),
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppDesign.bodySmall.copyWith(
            color: AppDesign.neutral400,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppDesign.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppDesign.neutral800,
          ),
        ),
      ],
    );
  }

  void _showCustomerDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailDialog(customer: customer),
    );
  }
}
