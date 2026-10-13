import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';

/// Modal dialog providing 360-degree customer details:
/// restaurant billing history, room stays, and loyalty tier status.
class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;

  const CustomerDetailDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 900,
        height: 700,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Restaurant Bills'),
                        Tab(text: 'Room Stays'),
                        Tab(text: 'Loyalty & Points'),
                      ],
                      labelColor: AppDesign.primaryStart,
                      indicatorColor: AppDesign.primaryStart,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildBillsList(db, context),
                          _buildBookingsList(db, context),
                          _buildLoyaltySection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppDesign.primaryStart, Color(0xFF3B449B)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Text(
              customer.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      customer.phone,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.email, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      customer.email ?? 'No email',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(DatabaseService db, BuildContext context) {
    final hotelId = context.hotelId;
    return FutureBuilder<List<Bill>>(
      future: db.getBillsByCustomerId(hotelId, customer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bills = snapshot.data ?? [];
        if (bills.isEmpty) {
          return const Center(child: Text('No order history found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: bills.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final bill = bills[index];
            return AppCard(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppDesign.neutral100,
                  child: Icon(
                    Icons.receipt_long,
                    color: AppDesign.neutral600,
                  ),
                ),
                title: Text(
                  'Bill #${bill.id.split('_').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${DateFormat('MMM dd, yyyy HH:mm').format(bill.openedAt)} • ${bill.orderIds.length} orders',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${bill.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bill.paymentStatus.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: bill.paymentStatus == PaymentStatus.paid
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsList(DatabaseService db, BuildContext context) {
    final hotelId = context.hotelId;
    return FutureBuilder<List<Booking>>(
      future: db.getBookingsByCustomerId(hotelId, customer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('No room stay history found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return AppCard(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppDesign.neutral100,
                  child: Icon(Icons.bed, color: AppDesign.neutral600),
                ),
                title: Text(
                  'Booking #${booking.id.split('_').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${DateFormat('MMM dd').format(booking.checkIn)} - ${DateFormat('MMM dd, yyyy').format(booking.checkOut)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${booking.totalAmount.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      booking.status.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoyaltySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomerDetailStatCard(
                  label: 'Available Points',
                  value: customer.loyaltyInfo?.availablePoints.toString() ?? '0',
                  color: Colors.green,
                  icon: Icons.stars,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomerDetailStatCard(
                  label: 'Lifetime Points',
                  value: customer.loyaltyInfo?.totalPoints.toString() ?? '0',
                  color: Colors.amber,
                  icon: Icons.military_tech,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.amber),
                    const SizedBox(width: 12),
                    Text(
                      'Tier Status',
                      style: AppDesign.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildTierBadge(
                      customer.loyaltyInfo?.tierId.split('_').last ?? 'Base',
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Member Since'),
                    Text(
                      customer.createdOn != null
                          ? DateFormat('MMM yyyy').format(customer.createdOn!)
                          : 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Loyalty Redemption Total'),
                    Text(
                      '₹${customer.loyaltyInfo?.lifetimeSpend.toInt() ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Active Offers Applied',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No manual offers applied in recent orders.',
                style: TextStyle(color: AppDesign.neutral400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        tier.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Stat display card used in customer analytics details
class CustomerDetailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const CustomerDetailStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral500),
          ),
        ],
      ),
    );
  }
}
