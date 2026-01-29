import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/services/database/interfaces/billing_database.dart';
import '../../../core/services/database_service.dart';
import '../../../theme/app_design.dart';
import 'package:intl/intl.dart';

class DiscountReportScreen extends StatefulWidget {
  const DiscountReportScreen({super.key});

  static const String routeName = '/discount-reports';

  @override
  State<DiscountReportScreen> createState() => _DiscountReportScreenState();
}

class _DiscountReportScreenState extends State<DiscountReportScreen> {
  final IBillingDatabase _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Discount Reports'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Bill>>(
        stream: _db.streamBills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bills = snapshot.data ?? [];
          final today = DateTime.now();
          final todaysBills = bills
              .where(
                (b) =>
                    b.openedAt.year == today.year &&
                    b.openedAt.month == today.month &&
                    b.openedAt.day == today.day,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildMetricGrid(todaysBills),
              const SizedBox(height: 24),
              _buildDiscountsList(todaysBills),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricGrid(List<Bill> bills) {
    double totalDiscounts = 0;
    int totalRedeemedPoints = 0;

    for (var bill in bills) {
      totalDiscounts += bill.discounts.fold(
        0.0,
        (sum, d) => sum + d.discountAmount,
      );
      totalRedeemedPoints += bill.redeemedPoints;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Discounts',
          '₹${totalDiscounts.toStringAsFixed(0)}',
          Icons.local_offer,
          Colors.orange,
        ),
        _buildMetricCard(
          'Points Redeemed',
          totalRedeemedPoints.toString(),
          Icons.star,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppDesign.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountsList(List<Bill> bills) {
    final allAppliedDiscounts = bills.expand((b) => b.discounts).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Applied Discounts (Today)',
              style: AppDesign.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (allAppliedDiscounts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No discounts applied today')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allAppliedDiscounts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final discount = allAppliedDiscounts[index];
                return ListTile(
                  title: Text(discount.name),
                  subtitle: Text(
                    DateFormat('h:mm a').format(discount.appliedAt),
                  ),
                  trailing: Text(
                    '-₹${discount.discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
