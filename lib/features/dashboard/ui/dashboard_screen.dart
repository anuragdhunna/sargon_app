import 'package:flutter/material.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/dashboard/logic/dashboard_cubit.dart';
import 'package:hotel_manager/features/dashboard/logic/dashboard_state.dart';
import 'package:hotel_manager/features/notifications/logic/notification_cubit.dart';
import 'package:hotel_manager/features/notifications/logic/notification_state.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hotel_manager/features/dashboard/ui/widgets/dashboard_components.dart';

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
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthVerified) {
      context.read<DashboardCubit>().refresh(authState.hotelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationLoaded) {
                unreadCount = state.unreadCount;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppDesign.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthVerified) {
                context.read<DashboardCubit>().refresh(authState.hotelId);
              }
            },
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
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthVerified) {
                        context.read<DashboardCubit>().refresh(
                          authState.hotelId,
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthVerified) {
                  context.read<DashboardCubit>().refresh(authState.hotelId);
                }
              },
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
            DashboardKpiItem(
              label: 'Open Tables',
              value: '${data.openTables}',
              icon: Icons.table_bar,
              color: Colors.orange,
              onTap: () => context.go('/tables'),
            ),
            DashboardKpiItem(
              label: 'Open Bills',
              value: '${data.openBills}',
              icon: Icons.receipt_long,
              color: Colors.blue,
              onTap: () => context.go('/order-history'),
            ),
            DashboardKpiItem(
              label: 'Active Orders',
              value: '${data.activeOrders}',
              icon: Icons.shopping_basket,
              color: Colors.green,
              onTap: () => context.go('/kitchen'),
            ),
            DashboardKpiItem(
              label: 'Kitchen Delays',
              value: '${data.kitchenDelays}',
              icon: Icons.timer,
              color: Colors.red,
              onTap: () => context.go('/kitchen'),
            ),
            DashboardKpiItem(
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
          DashboardSalesRow(
            label: 'Gross Sales',
            value: currencyFormat.format(data.grossSales),
            isHeader: true,
          ),
          const Divider(),
          DashboardSalesRow(
            label: 'Net Sales',
            value: currencyFormat.format(data.netSales),
            color: Colors.green,
          ),
          DashboardSalesRow(
            label: 'Total Discounts',
            value: currencyFormat.format(data.totalDiscounts),
            color: Colors.red,
          ),
          DashboardSalesRow(
            label: 'GST Collected',
            value: currencyFormat.format(data.gstCollected),
          ),
          DashboardSalesRow(
            label: 'Service Charge',
            value: currencyFormat.format(data.serviceChargeCollected),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DashboardMetricMini(
                label: 'Total Bills',
                value: '${data.billsCount}',
              ),
              DashboardMetricMini(
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
            DashboardBillingStatusItem(
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
            DashboardPaymentSplitRow(
              icon: Icons.money,
              label: 'Cash',
              value: data.cashTotal,
              color: Colors.green,
            ),
            DashboardPaymentSplitRow(
              icon: Icons.credit_card,
              label: 'Card',
              value: data.cardTotal,
              color: Colors.blue,
            ),
            DashboardPaymentSplitRow(
              icon: Icons.qr_code,
              label: 'Online/UPI',
              value: data.onlineTotal,
              color: Colors.purple,
            ),
            DashboardPaymentSplitRow(
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
                child: DashboardStatusBox(
                  label: 'Cooking',
                  value: '${data.ordersCooking}',
                  color: Colors.blue,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatusBox(
                  label: 'Ready',
                  value: '${data.ordersReady}',
                  color: Colors.green,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatusBox(
                  label: 'Delayed Items',
                  value: '${data.delayedItems}',
                  color: Colors.red,
                  onTap: () => context.go('/kitchen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardStatusBox(
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
