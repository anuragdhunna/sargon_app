import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/widgets/add_customer_dialog.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/widgets/customer_analytics_cards.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';

/// Screen providing high-level customer insights, metrics, and search
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        label: const Text('Add Customer'),
        icon: const Icon(Icons.add),
        backgroundColor: AppDesign.primaryStart,
        foregroundColor: Colors.white,
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
          SummaryCard(
            label: 'Total Customers',
            value: customers.length.toString(),
            icon: Icons.people_alt_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 24),
          SummaryCard(
            label: 'Lifetime Revenue',
            value: '₹${NumberFormat('#,##,###').format(totalSpent)}',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
          ),
          const SizedBox(width: 24),
          SummaryCard(
            label: 'Total Stays',
            value: totalBookings.toString(),
            icon: Icons.bed_rounded,
            color: Colors.orange,
          ),
          const SizedBox(width: 24),
          if (topCustomer != null)
            SummaryCard(
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
        return CustomerCard(customer: customers[index]);
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: const AddCustomerDialog(),
      ),
    );
  }
}
