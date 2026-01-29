import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/dashboard/logic/dashboard_cubit.dart';
import 'package:hotel_manager/features/dashboard/logic/dashboard_state.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardCubit>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load dashboard: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKPIStrip(context, state.data),
                    const SizedBox(height: 24),
                    _buildTwoColumnSection(context, state.data),
                    const SizedBox(height: 24),
                    _buildOrderKDSSummary(context, state.data),
                    const SizedBox(height: 24),
                    _buildTopDishes(state.data),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildKPIStrip(BuildContext context, DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 5
            : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _KPIItem(
              label: 'Open Tables',
              value: '${data.openTables}',
              icon: Icons.table_bar,
              color: Colors.orange,
              onTap: () => context.go('/tables'),
            ),
            _KPIItem(
              label: 'Open Bills',
              value: '${data.openBills}',
              icon: Icons.receipt_long,
              color: Colors.blue,
              onTap: () => context.go('/order-history'),
            ),
            _KPIItem(
              label: 'Active Orders',
              value: '${data.activeOrders}',
              icon: Icons.shopping_basket,
              color: Colors.green,
              onTap: () => context.go('/kitchen'),
            ),
            _KPIItem(
              label: 'Kitchen Delays',
              value: '${data.kitchenDelays}',
              icon: Icons.timer,
              color: Colors.red,
              onTap: () => context.go('/kitchen'),
            ),
            _KPIItem(
              label: 'Room Pending',
              value: '₹${data.billToRoomTotal.toStringAsFixed(0)}',
              icon: Icons.meeting_room,
              color: Colors.purple,
              onTap: () => context.go('/rooms'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTwoColumnSection(BuildContext context, DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildSalesSnapshot(context, data)),
              const SizedBox(width: 24),
              Expanded(child: _buildBillingSummary(context, data)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildSalesSnapshot(context, data),
              const SizedBox(height: 24),
              _buildBillingSummary(context, data),
            ],
          );
        }
      },
    );
  }

  Widget _buildSalesSnapshot(BuildContext context, DashboardData data) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Snapshot (Today)', style: AppDesign.titleLarge),
          const SizedBox(height: 16),
          _SalesRow(
            label: 'Gross Sales',
            value: currencyFormat.format(data.grossSales),
            isHeader: true,
          ),
          const Divider(),
          _SalesRow(
            label: 'Net Sales',
            value: currencyFormat.format(data.netSales),
            color: Colors.green,
          ),
          _SalesRow(
            label: 'Total Discounts',
            value: currencyFormat.format(data.totalDiscounts),
            color: Colors.red,
          ),
          _SalesRow(
            label: 'GST Collected',
            value: currencyFormat.format(data.gstCollected),
          ),
          _SalesRow(
            label: 'Service Charge',
            value: currencyFormat.format(data.serviceChargeCollected),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricMini(label: 'Total Bills', value: '${data.billsCount}'),
              _MetricMini(
                label: 'Avg Bill',
                value: currencyFormat.format(data.avgBillValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSummary(BuildContext context, DashboardData data) {
    return AppCard(
      child: InkWell(
        onTap: () => context.go('/order-history'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing & Payments', style: AppDesign.titleLarge),
            const SizedBox(height: 16),
            _BillingStatusItem(
              label: 'Unpaid Bills',
              count: data.unpaidBillsCount,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Mode Split',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _PaymentSplitRow(
              icon: Icons.money,
              label: 'Cash',
              value: data.cashTotal,
              color: Colors.green,
            ),
            _PaymentSplitRow(
              icon: Icons.credit_card,
              label: 'Card',
              value: data.cardTotal,
              color: Colors.blue,
            ),
            _PaymentSplitRow(
              icon: Icons.qr_code,
              label: 'Online/UPI',
              value: data.onlineTotal,
              color: Colors.purple,
            ),
            _PaymentSplitRow(
              icon: Icons.hotel,
              label: 'Bill to Room',
              value: data.billToRoomTotal,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderKDSSummary(BuildContext context, DashboardData data) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order & KDS Operations', style: AppDesign.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatusBox(
                  label: 'Cooking',
                  value: '${data.ordersCooking}',
                  color: Colors.blue,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatusBox(
                  label: 'Ready',
                  value: '${data.ordersReady}',
                  color: Colors.green,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatusBox(
                  label: 'Delayed Items',
                  value: '${data.delayedItems}',
                  color: Colors.red,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatusBox(
                  label: 'VIP/Rush',
                  value: '${data.vipRushOrders}',
                  color: Colors.orange,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopDishes(DashboardData data) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Selling Dishes', style: AppDesign.titleLarge),
          const SizedBox(height: 16),
          if (data.topDishes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No orders yet today.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.topDishes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dish = data.topDishes[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppDesign.primaryStart.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppDesign.primaryStart,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    dish['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Qty: ${dish['qty']} sold today'),
                  trailing: Text(
                    '₹${(dish['sales'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _KPIItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _KPIItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppDesign.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isHeader;

  const _SalesRow({
    required this.label,
    required this.value,
    this.color,
    this.isHeader = false,
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
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isHeader ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  final String label;
  final String value;

  const _MetricMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _BillingStatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _BillingStatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSplitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _PaymentSplitRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatusBox({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppDesign.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
