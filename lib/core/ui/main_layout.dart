import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/dialogs/confirmation_dialog.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/core/models/user_model.dart';
import 'package:hotel_manager/features/dashboard/ui/dashboard_screen.dart';
import 'package:hotel_manager/features/loyalty/presentation/screens/loyalty_management_screen.dart';
import 'package:hotel_manager/features/offers/presentation/screens/offer_management_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/user_management_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/customer_analytics_screen.dart';
import 'package:hotel_manager/features/rooms/ui/rooms_screen.dart';
import 'package:hotel_manager/features/inventory/stock/presentation/inventory_screen.dart';
import 'package:hotel_manager/features/orders/ui/order_taking_screen.dart';
import 'package:hotel_manager/features/orders/ui/kitchen_screen.dart';
import 'package:hotel_manager/features/orders/ui/order_history_screen.dart';
import 'package:hotel_manager/features/checklists/ui/checklist_list_screen.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_screen.dart';
import 'package:hotel_manager/features/incidents/ui/incident_management_screen.dart';
import 'package:hotel_manager/features/performance/ui/employee_performance_screen.dart';
import 'package:hotel_manager/features/audit/ui/audit_log_screen.dart';
import 'package:hotel_manager/features/auth/ui/login_screen.dart';
import 'package:hotel_manager/features/table_mgmt/ui/table_dashboard_screen.dart';
import 'package:hotel_manager/features/orders/ui/kds_analytics_screen.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Get current role
    final authState = context.read<AuthCubit>().state;
    final UserRole role = (authState is AuthVerified)
        ? authState.role
        : UserRole.owner;

    final destinations = _getDestinationsForRole(role);
    final selectedIndex = _getSelectedIndex(location, destinations);

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72, maxWidth: 100),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) =>
                          _onItemTapped(index, context, destinations),
                      labelType: NavigationRailLabelType.all,
                      destinations: destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: Icon(d.icon),
                              label: Text(d.label),
                            ),
                          )
                          .toList(),
                      trailing: Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: IconButton(
                              icon: const Icon(Icons.logout),
                              tooltip: 'Logout',
                              onPressed: () async {
                                final confirmed =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (_) => const ConfirmationDialog(
                                        title: 'Logout',
                                        message:
                                            'Are you sure you want to logout?',
                                        confirmText: 'Logout',
                                        icon: Icon(
                                          Icons.logout,
                                          size: 48,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ) ??
                                    false;

                                if (confirmed && context.mounted) {
                                  context.read<AuthCubit>().logout();
                                  context.go(LoginScreen.routeName);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onTap: (index) => _onItemTapped(index, context, destinations),
              type: BottomNavigationBarType.fixed,
              items: destinations
                  .map(
                    (d) => BottomNavigationBarItem(
                      icon: Icon(d.icon),
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  List<NavDestination> _getDestinationsForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
      case UserRole.manager:
        return [
          const NavDestination(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: DashboardScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.table_chart,
            label: 'Floor View',
            route: TableDashboardScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.people,
            label: 'Staff',
            route: UserManagementScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.analytics_outlined,
            label: 'Customers',
            route: CustomerAnalyticsScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.bed,
            label: 'Rooms',
            route: RoomsScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.inventory,
            label: 'Inventory',
            route: InventoryScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.restaurant,
            label: 'Order',
            route: OrderTakingScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.kitchen,
            label: 'Kitchen',
            route: KitchenScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.history,
            label: 'Order History',
            route: OrderHistoryScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.bar_chart,
            label: 'KDS Performance',
            route: KdsAnalyticsScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.checklist,
            label: 'Checklists',
            route: ChecklistListScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.access_time,
            label: 'Attendance',
            route: AttendanceScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.report_problem,
            label: 'Incidents',
            route: IncidentManagementScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.analytics,
            label: 'Performance',
            route: EmployeePerformanceScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.history,
            label: 'Audit Logs',
            route: AuditLogScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.local_offer,
            label: 'Offers',
            route: OfferManagementScreen.routeName,
          ),
          const NavDestination(
            icon: Icons.star,
            label: 'Loyalty',
            route: LoyaltyManagementScreen.routeName,
          ),
        ];
      case UserRole.frontDesk:
        return const [
          NavDestination(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: DashboardScreen.routeName,
          ),
          NavDestination(
            icon: Icons.bed,
            label: 'Rooms',
            route: RoomsScreen.routeName,
          ),
          NavDestination(
            icon: Icons.report_problem,
            label: 'Incidents',
            route: IncidentManagementScreen.routeName,
          ),
          NavDestination(
            icon: Icons.access_time,
            label: 'Attendance',
            route: AttendanceScreen.routeName,
          ),
        ];
      case UserRole.housekeeping:
        return const [
          NavDestination(
            icon: Icons.checklist,
            label: 'My Tasks',
            route: ChecklistListScreen.routeName,
          ),
          NavDestination(
            icon: Icons.inventory,
            label: 'Inventory',
            route: InventoryScreen.routeName,
          ),
          NavDestination(
            icon: Icons.report_problem,
            label: 'Incidents',
            route: IncidentManagementScreen.routeName,
          ),
          NavDestination(
            icon: Icons.access_time,
            label: 'Attendance',
            route: AttendanceScreen.routeName,
          ),
        ];
      case UserRole.waiter:
        return const [
          NavDestination(
            icon: Icons.restaurant_menu,
            label: 'Order',
            route: OrderTakingScreen.routeName,
          ),
          NavDestination(
            icon: Icons.access_time,
            label: 'Attendance',
            route: AttendanceScreen.routeName,
          ),
        ];
      case UserRole.chef:
        return const [
          NavDestination(
            icon: Icons.kitchen,
            label: 'KDS',
            route: KitchenScreen.routeName,
          ),
          NavDestination(
            icon: Icons.inventory,
            label: 'Inventory',
            route: InventoryScreen.routeName,
          ),
          NavDestination(
            icon: Icons.access_time,
            label: 'Attendance',
            route: AttendanceScreen.routeName,
          ),
        ];
      default:
        return const [
          NavDestination(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: DashboardScreen.routeName,
          ),
        ];
    }
  }

  int _getSelectedIndex(String location, List<NavDestination> destinations) {
    // Exact match first
    for (int i = 0; i < destinations.length; i++) {
      if (location == destinations[i].route) return i;
    }

    // Prefix match with separator check
    for (int i = 0; i < destinations.length; i++) {
      final route = destinations[i].route;
      if (location.startsWith(route)) {
        // Ensure it's a full path segment match (e.g., /orders/1 matches /orders, but /order-history doesn't match /order)
        if (location.length == route.length ||
            location[route.length] == '/' ||
            location[route.length] == '?') {
          return i;
        }
      }
    }
    return 0;
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    List<NavDestination> destinations,
  ) {
    if (index >= 0 && index < destinations.length) {
      context.go(destinations[index].route);
    }
  }
}

class NavDestination {
  final IconData icon;
  final String label;
  final String route;

  const NavDestination({
    required this.icon,
    required this.label,
    required this.route,
  });
}
