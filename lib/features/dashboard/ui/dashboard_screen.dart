import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/dialogs/confirmation_dialog.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
import 'package:hotel_manager/features/dashboard/presentation/widgets/placeholder_card.dart';

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
            DashboardStatsGrid(isDesktop: isDesktop, isTablet: isTablet),
            const SizedBox(height: 24),

            // Live Room Status (Placeholder for now)
            Text(
              'Live Room Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const PlaceholderCard(title: 'Room Map Visualization Coming Soon'),
          ],
        ),
      ),
    );
  }
}
