import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/cards/stat_card.dart';
import 'package:hotel_manager/component/dialogs/confirmation_dialog.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    // Responsive Breakpoints
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmationDialog(
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      icon: Icon(Icons.logout, size: 48, color: Colors.orange),
                    ),
                  ) ??
                  false;

              if (confirmed && context.mounted) {
                context.read<AuthCubit>().logout();
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            StaggeredGrid.count(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                const StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: StatCard(
                    title: 'Revenue',
                    value: '₹1.2L',
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),
                ),
                const StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: StatCard(
                    title: 'Occupancy',
                    value: '85%',
                    icon: Icons.hotel,
                    color: Colors.blue,
                  ),
                ),
                const StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: StatCard(
                    title: 'Incidents',
                    value: '3',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ),
                const StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: StatCard(
                    title: 'Staff Active',
                    value: '12/15',
                    icon: Icons.people,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live Room Status (Placeholder for now)
            Text(
              'Live Room Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text('Room Map Visualization Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
