import 'package:flutter/material.dart';
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
import 'package:hotel_manager/features/orders/presentation/kitchen/ui/kitchen_screen.dart';
import 'package:hotel_manager/features/orders/presentation/order_taking/ui/order_taking_screen.dart';
import 'package:hotel_manager/features/orders/presentation/order_history/ui/order_history_screen.dart';
import 'package:hotel_manager/features/performance/ui/employee_performance_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/user_management_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/customer_analytics_screen.dart';
import 'package:hotel_manager/features/rooms/ui/rooms_screen.dart';
import 'package:hotel_manager/features/rooms/ui/booking_history_screen.dart';
import 'package:hotel_manager/features/table_mgmt/ui/table_dashboard_screen.dart';
import 'package:hotel_manager/features/rooms/ui/room_folio_screen.dart';
import 'package:hotel_manager/features/orders/presentation/kitchen/ui/kds_analytics_screen.dart';
import 'package:hotel_manager/features/billing/ui/billing_screen.dart';
import 'package:hotel_manager/features/billing/ui/discount_report_screen.dart';
import 'package:hotel_manager/features/offers/presentation/screens/offer_management_screen.dart';
import 'package:hotel_manager/features/loyalty/presentation/screens/loyalty_management_screen.dart';
import 'package:hotel_manager/core/models/models.dart';

/// Auth state notifier for GoRouter refresh
///
/// This allows GoRouter to re-evaluate redirect when auth state changes.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._authCubit) {
    _authCubit.stream.listen((state) {
      notifyListeners();
    });
  }

  final AuthCubit _authCubit;

  AuthState get authState => _authCubit.state;
  bool get isAuthenticated => _authCubit.state is AuthVerified;
}

/// Create the app router with auth state refresh support
GoRouter createRouter(AuthCubit authCubit) {
  final authNotifier = AuthNotifier(authCubit);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.authState;

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
        final verifiedState = authState;
        return RoleGuard.getDefaultRoute(verifiedState.role);
      }

      // Check role-based access
      if (isAuthenticated && !isLoginRoute) {
        final verifiedState = authState;
        final route = state.matchedLocation
            .split('?')
            .first; // Remove query params

        if (!RoleGuard.canAccess(verifiedState.role, route)) {
          // Redirect to default route if unauthorized
          return RoleGuard.getDefaultRoute(verifiedState.role);
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
            path: CustomerAnalyticsScreen.routeName,
            builder: (context, state) => const CustomerAnalyticsScreen(),
          ),
          GoRoute(
            path: InventoryScreen.routeName,
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: OrderTakingScreen.routeName,
            builder: (context, state) {
              final tableId = state.uri.queryParameters['tableId'];
              final roomId = state.uri.queryParameters['roomId'];
              return OrderTakingScreen(tableId: tableId, roomId: roomId);
            },
          ),
          GoRoute(
            path: OrderHistoryScreen.routeName,
            builder: (context, state) {
              final bookingId = state.uri.queryParameters['bookingId'];
              return OrderHistoryScreen(initialBookingId: bookingId);
            },
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
            path: BookingHistoryScreen.routeName,
            builder: (context, state) => const BookingHistoryScreen(),
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
            path: TableDashboardScreen.routeName,
            builder: (context, state) => const TableDashboardScreen(),
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
          GoRoute(
            path: '/folio/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return RoomFolioScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: KdsAnalyticsScreen.routeName,
            builder: (context, state) => const KdsAnalyticsScreen(),
          ),
          GoRoute(
            path: BillingScreen.routeName,
            builder: (context, state) {
              final tableId = state.uri.queryParameters['tableId']!;
              final tableNumber = state.uri.queryParameters['tableNumber'];
              final orders = state.extra as List<Order>;
              return BillingScreen(
                tableId: tableId,
                tableNumber: tableNumber,
                orders: orders,
              );
            },
          ),
          GoRoute(
            path: DiscountReportScreen.routeName,
            builder: (context, state) => const DiscountReportScreen(),
          ),
          GoRoute(
            path: OfferManagementScreen.routeName,
            builder: (context, state) => const OfferManagementScreen(),
          ),
          GoRoute(
            path: LoyaltyManagementScreen.routeName,
            builder: (context, state) => const LoyaltyManagementScreen(),
          ),
        ],
      ),
    ],
  );
}
