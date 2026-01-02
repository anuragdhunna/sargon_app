import 'package:hotel_manager/core/models/user_model.dart';
import 'package:hotel_manager/features/dashboard/ui/dashboard_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/user_management_screen.dart';
import 'package:hotel_manager/features/rooms/ui/rooms_screen.dart';
import 'package:hotel_manager/features/inventory/stock/presentation/inventory_screen.dart';
import 'package:hotel_manager/features/orders/ui/order_taking_screen.dart';
import 'package:hotel_manager/features/orders/ui/kitchen_screen.dart';
import 'package:hotel_manager/features/checklists/ui/checklist_list_screen.dart';
import 'package:hotel_manager/features/attendance/ui/attendance_screen.dart';
import 'package:hotel_manager/features/incidents/ui/incident_management_screen.dart';
import 'package:hotel_manager/features/performance/ui/employee_performance_screen.dart';
import 'package:hotel_manager/features/audit/ui/audit_log_screen.dart';
import 'package:hotel_manager/features/rooms/ui/booking_history_screen.dart';
import 'package:hotel_manager/features/table_mgmt/ui/table_dashboard_screen.dart';
import 'package:hotel_manager/features/orders/ui/kds_analytics_screen.dart';

class RoleGuard {
  /// Check if a user role has access to a specific route
  static bool canAccess(UserRole role, String route) {
    // Owner has access to everything
    if (role == UserRole.owner) return true;

    // Handle sub-routes by checking prefixes
    if (route.startsWith(AttendanceScreen.routeName)) {
      // Basic attendance is for everyone
      if (route == AttendanceScreen.routeName) return true;

      // Reports, Live Dashboard, Calendar - Manager only
      if (route.startsWith('${AttendanceScreen.routeName}/')) {
        return role == UserRole.manager;
      }
    }

    if (route.startsWith(ChecklistListScreen.routeName)) {
      if (route == ChecklistListScreen.routeName) {
        return [
          UserRole.manager,
          UserRole.chef,
          UserRole.waiter,
          UserRole.housekeeping,
        ].contains(role);
      }
      // Create/Edit - Manager only
      return role == UserRole.manager;
    }

    switch (route) {
      // Dashboard - Manager, FrontDesk
      case DashboardScreen.routeName:
        return [UserRole.manager, UserRole.frontDesk].contains(role);

      // Staff Management - Manager
      case UserManagementScreen.routeName:
        return role == UserRole.manager;

      // Inventory - Manager, Chef, Housekeeping (view only)
      case InventoryScreen.routeName:
        return [
          UserRole.manager,
          UserRole.chef,
          UserRole.housekeeping,
        ].contains(role);

      // Order Taking - Manager, Waiter
      case OrderTakingScreen.routeName:
        return [UserRole.manager, UserRole.waiter].contains(role);

      // Kitchen Display - Manager, Chef
      case KitchenScreen.routeName:
        return [UserRole.manager, UserRole.chef].contains(role);

      // Incidents - Manager, FrontDesk, Housekeeping
      case IncidentManagementScreen.routeName:
        return [
          UserRole.manager,
          UserRole.frontDesk,
          UserRole.housekeeping,
        ].contains(role);

      // Room Management - Front Desk, Manager
      case RoomsScreen.routeName:
      case BookingHistoryScreen.routeName:
        return [UserRole.manager, UserRole.frontDesk].contains(role);

      // Performance - Manager only
      case EmployeePerformanceScreen.routeName:
        return role == UserRole.manager;

      // Audit Logs - Manager only
      case AuditLogScreen.routeName:
        return role == UserRole.manager;

      case TableDashboardScreen.routeName:
        return [UserRole.manager, UserRole.owner].contains(role);

      case KdsAnalyticsScreen.routeName:
        return [UserRole.manager, UserRole.chef, UserRole.owner].contains(role);

      default:
        // Folio route uses parameters, need prefix check
        if (route.startsWith('/folio/')) {
          return [
            UserRole.manager,
            UserRole.frontDesk,
            UserRole.owner,
          ].contains(role);
        }
        return false;
    }
  }

  /// Get the default route for a role (where they should land after login)
  static String getDefaultRoute(UserRole role) {
    switch (role) {
      case UserRole.owner:
      case UserRole.manager:
      case UserRole.frontDesk:
        return DashboardScreen.routeName;
      case UserRole.waiter:
        return OrderTakingScreen.routeName;
      case UserRole.chef:
        return KitchenScreen.routeName;
      case UserRole.housekeeping:
        return ChecklistListScreen.routeName;
      default:
        return DashboardScreen.routeName;
    }
  }
}
