import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/core/auth/role_guard.dart';
import 'package:hotel_manager/core/ui/main_layout.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_screen.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_reports_screen.dart';
import 'package:hotel_manager/features/attendance/ui/live_attendance_dashboard.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_calendar_screen.dart';
import 'package:hotel_manager/features/audit/ui/audit_log_screen.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/auth/ui/login_screen.dart';
import 'package:hotel_manager/features/auth/ui/otp_screen.dart';
import 'package:hotel_manager/features/checklists/ui/checklist_list_screen.dart';
import 'package:hotel_manager/features/checklists/ui/create_checklist_screen.dart';
import 'package:hotel_manager/features/dashboard/ui/dashboard_screen.dart';
import 'package:hotel_manager/features/incidents/ui/incident_management_screen.dart';
import 'package:hotel_manager/features/inventory/stock/presentation/inventory_screen.dart';
import 'package:hotel_manager/features/orders/ui/kitchen_screen.dart';
import 'package:hotel_manager/features/orders/ui/order_taking_screen.dart';
import 'package:hotel_manager/features/performance/ui/employee_performance_screen.dart';
import 'package:hotel_manager/features/rooms/ui/rooms_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/user_management_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authCubit = context.read<AuthCubit>();
      final authState = authCubit.state;

      // Check if user is authenticated
      final isAuthenticated = authState is AuthVerified;
      final isLoginRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/otp';

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoginRoute) {
        return LoginScreen.routeName;
      }

      // If authenticated and on login page, redirect to default route for role
      if (isAuthenticated && isLoginRoute) {
        final role = (authState).role;
        return RoleGuard.getDefaultRoute(role);
      }

      // Check role-based access
      if (isAuthenticated && !isLoginRoute) {
        final role = (authState).role;
        final route = state.matchedLocation
            .split('?')
            .first; // Remove query params

        if (!RoleGuard.canAccess(role, route)) {
          // Redirect to default route if unauthorized
          return RoleGuard.getDefaultRoute(role);
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(location: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: UserManagementScreen.routeName,
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: InventoryScreen.routeName,
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: OrderTakingScreen.routeName,
            builder: (context, state) => const OrderTakingScreen(),
          ),
          GoRoute(
            path: ChecklistListScreen.routeName,
            builder: (context, state) => const ChecklistListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateChecklistScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoomsScreen.routeName,
            builder: (context, state) => const RoomsScreen(),
          ),
          GoRoute(
            path: AuditLogScreen.routeName,
            name: AuditLogScreen.routeName,
            builder: (context, state) => const AuditLogScreen(),
          ),
          GoRoute(
            path: KitchenScreen.routeName,
            builder: (context, state) => const KitchenScreen(),
          ),
          GoRoute(
            path: AttendanceScreen.routeName,
            builder: (context, state) => const AttendanceScreen(),
            routes: [
              GoRoute(
                path: AttendanceReportsScreen.routeName,
                builder: (context, state) => const AttendanceReportsScreen(),
              ),
              GoRoute(
                path: LiveAttendanceDashboard.routeName,
                builder: (context, state) => const LiveAttendanceDashboard(),
              ),
              GoRoute(
                path: AttendanceCalendarScreen.routeName,
                builder: (context, state) => const AttendanceCalendarScreen(),
              ),
            ],
          ),
          GoRoute(
            path: IncidentManagementScreen.routeName,
            builder: (context, state) => const IncidentManagementScreen(),
          ),
          GoRoute(
            path: EmployeePerformanceScreen.routeName,
            builder: (context, state) => const EmployeePerformanceScreen(),
          ),
        ],
      ),
    ],
  );
}
