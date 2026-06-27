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
import 'package:hotel_manager/features/staff_mgmt/ui/owner_management_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/create_owner_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/edit_owner_screen.dart';
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
import 'package:hotel_manager/features/settings/presentation/settings_screen.dart';
import 'package:hotel_manager/features/settings/presentation/menu/menu_management_screen.dart';
import 'package:hotel_manager/features/settings/presentation/tables/table_management_screen.dart';
import 'package:hotel_manager/features/settings/presentation/tax/tax_settings_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/hall_management_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_list_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_creation_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_details_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_billing_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_reporting_screen.dart';
import 'package:hotel_manager/features/events/presentation/screens/event_calendar_screen.dart';
import 'package:hotel_manager/features/notifications/presentation/notification_screen.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/screens/cart_screen.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/screens/order_confirmation_screen.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/screens/menu_screen.dart';
import 'package:hotel_manager/core/models/models.dart';

/// Auth state notifier for GoRouter refresh
///
/// This allows GoRouter to re-evaluate redirect when auth state changes.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._authCubit) {
    _authCubit.stream.listen((state) {
      final lastState = _lastState;
      if (lastState.runtimeType != state.runtimeType ||
          (state is AuthVerified &&
              lastState is AuthVerified &&
              state.role != lastState.role)) {
        debugPrint('🔄 AuthNotifier: State changed to ${state.runtimeType}');
        _lastState = state;
        notifyListeners();
      }
    });
  }

  final AuthCubit _authCubit;
  AuthState _lastState = AuthInitial();

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
      final location = state.matchedLocation;

      // Check if user is authenticated
      final isAuthenticated = authState is AuthVerified;
      final isLoginRoute = location == '/login' || location == '/otp';

      debugPrint('🚀 Router Redirect: $location (Auth: $isAuthenticated)');

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoginRoute) {
        debugPrint('↪️ Redirecting to login: Unauthorized');
        return LoginScreen.routeName;
      }

      // If authenticated and on login page, redirect to default route for role
      if (authState is AuthVerified && isLoginRoute) {
        final defaultRoute = RoleGuard.getDefaultRoute(authState.role);
        debugPrint('↪️ Redirecting to $defaultRoute: Already Authenticated');
        return defaultRoute;
      }

      // Check role-based access
      if (authState is AuthVerified && !isLoginRoute) {
        final route = location.split('?').first; // Remove query params

        if (!RoleGuard.canAccess(authState.role, route)) {
          final defaultRoute = RoleGuard.getDefaultRoute(authState.role);
          // Only redirect if we are not already at the default route to avoid infinite loops
          if (route != defaultRoute) {
            debugPrint(
              '↪️ Redirecting to $defaultRoute: Access Denied for $route',
            );
            return defaultRoute;
          }
          // If we are at the default route but access is still denied,
          // this is a critical loop. We should go back to login as safety.
          debugPrint(
            '❌ CRITICAL: Access denied to default route $defaultRoute. Safety log out.',
          );
          return LoginScreen.routeName;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      // Customer ordering routes (public - no authentication required)
      GoRoute(path: '/customer/menu', builder: (context, state) => const MenuScreen()),
      GoRoute(path: '/customer/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/customer/order-confirmation', builder: (context, state) => const OrderConfirmationScreen()),
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
            path: OwnerManagementScreen.routeName,
            builder: (context, state) => const OwnerManagementScreen(),
          ),
          GoRoute(
            path: CreateOwnerScreen.routeName,
            builder: (context, state) => const CreateOwnerScreen(),
          ),
          GoRoute(
            path: EditOwnerScreen.routeName,
            builder: (context, state) {
              final owner = state.extra as User;
              return EditOwnerScreen(owner: owner);
            },
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
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) =>
                    EventCreationScreen(event: state.extra as PrivateEvent?),
              ),
              GoRoute(
                path: 'details',
                builder: (context, state) =>
                    EventDetailsScreen(event: state.extra as PrivateEvent),
              ),
              GoRoute(
                path: 'billing',
                builder: (context, state) =>
                    EventBillingScreen(event: state.extra as PrivateEvent),
              ),
              GoRoute(
                path: 'reports',
                builder: (context, state) => const EventReportingScreen(),
              ),
              GoRoute(
                path: 'calendar',
                builder: (context, state) => const EventCalendarScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) => const MenuManagementScreen(),
          ),
          GoRoute(
            path: 'tables',
            builder: (context, state) => const TableManagementScreen(),
          ),
          GoRoute(
            path: 'tax',
            builder: (context, state) => const TaxSettingsScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AuditLogScreen(),
          ),
          GoRoute(
            path: 'halls',
            builder: (context, state) => const HallManagementScreen(),
          ),
        ],
      ),
    ],
  );
}
