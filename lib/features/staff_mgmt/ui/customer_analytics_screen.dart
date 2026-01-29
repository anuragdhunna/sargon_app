import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:intl/intl.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  static const String routeName = '/customers';

  @override
  State<CustomerAnalyticsScreen> createState() =>
      _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  String _searchQuery = '';
  String _sortBy = 'Spent'; // Spent, Last Visit, Bookings, Name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Customer Insights & Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [_buildSortDropdown(), const SizedBox(width: 16)],
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is CustomerLoaded) {
            final filteredCustomers = _filterAndSort(state.customers);

            return Column(
              children: [
                _buildSummaryHeader(state.customers),
                _buildSearchSection(),
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? const Center(child: Text('No customers found.'))
                      : _buildCustomerGrid(filteredCustomers),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryHeader(List<Customer> customers) {
    final totalSpent = customers.fold(0.0, (sum, c) => sum + c.totalSpent);
    final totalBookings = customers.fold(0, (sum, c) => sum + c.totalBookings);
    final topCustomer = customers.isEmpty
        ? null
        : customers.reduce((a, b) => a.totalSpent > b.totalSpent ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppDesign.neutral200)),
      ),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Total Customers',
            value: customers.length.toString(),
            icon: Icons.people_alt_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 24),
          _SummaryCard(
            label: 'Lifetime Revenue',
            value: '₹${NumberFormat('#,##,###').format(totalSpent)}',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
          ),
          const SizedBox(width: 24),
          _SummaryCard(
            label: 'Total Stays',
            value: totalBookings.toString(),
            icon: Icons.bed_rounded,
            color: Colors.orange,
          ),
          const SizedBox(width: 24),
          if (topCustomer != null)
            _SummaryCard(
              label: 'Top Customer',
              value: topCustomer.name,
              subValue: 'Spent ₹${topCustomer.totalSpent.toInt()}',
              icon: Icons.workspace_premium_rounded,
              color: Colors.amber,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppTextField(
                hintText: 'Search by name or phone...',
                prefixIcon: Icons.search,
                onChanged: (val) => setState(() => _searchQuery = val ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      underline: const SizedBox(),
      icon: const Icon(Icons.sort_rounded),
      items: ['Spent', 'Last Visit', 'Bookings', 'Name']
          .map((e) => DropdownMenuItem(value: e, child: Text('Sort by $e')))
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _sortBy = val);
      },
    );
  }

  List<Customer> _filterAndSort(List<Customer> customers) {
    var filtered = customers.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) || c.phone.contains(query);
    }).toList();

    switch (_sortBy) {
      case 'Spent':
        filtered.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case 'Last Visit':
        filtered.sort(
          (a, b) => (b.lastVisit ?? DateTime(2000)).compareTo(
            a.lastVisit ?? DateTime(2000),
          ),
        );
        break;
      case 'Bookings':
        filtered.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
        break;
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  Widget _buildCustomerGrid(List<Customer> customers) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return _CustomerCard(customer: customers[index]);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;

  const _SummaryCard({
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

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  const _CustomerCard({required this.customer});

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
                    customer.name[0].toUpperCase(),
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
                _buildStat('Total Spent', '₹${customer.totalSpent.toInt()}'),
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
      builder: (context) => _CustomerDetailDialog(customer: customer),
    );
  }
}

class _CustomerDetailDialog extends StatelessWidget {
  final Customer customer;
  const _CustomerDetailDialog({required this.customer});

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
                          _buildBillsList(db),
                          _buildBookingsList(db),
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

  Widget _buildBillsList(DatabaseService db) {
    return FutureBuilder<List<Bill>>(
      future: db.getBillsByCustomerId(customer.id),
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final bill = bills[index];
            return AppCard(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppDesign.neutral100,
                  child: Icon(Icons.receipt_long, color: AppDesign.neutral600),
                ),
                title: Text(
                  'Bill #${bill.id.split('_').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(bill.openedAt),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${bill.grandTotal.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppDesign.primaryStart,
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

  Widget _buildBookingsList(DatabaseService db) {
    return FutureBuilder<List<Booking>>(
      future: db.getBookingsByCustomerId(customer.id),
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                child: _DetailStatCard(
                  label: 'Available Points',
                  value:
                      customer.loyaltyInfo?.availablePoints.toString() ?? '0',
                  color: Colors.green,
                  icon: Icons.stars,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DetailStatCard(
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
                      customer.createdAt != null
                          ? DateFormat('MMM yyyy').format(customer.createdAt!)
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
          // In a real app, we'd fetch actual offer redemptions.
          // For now, based on totalSpend we can show a summary.
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

class _DetailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _DetailStatCard({
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
