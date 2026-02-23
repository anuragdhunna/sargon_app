import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/incidents/logic/incident_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/inventory/inventory_index.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';

class HotelManagerApp extends StatelessWidget {
  final GoRouter router;

  const HotelManagerApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthVerified) {
          final hotelId = state.hotelId;

          // Propagate hotelId to services and cubits immediately
          if (context.mounted) {
            // Core Logic
            context.read<TableCubit>().loadTables(hotelId);
            context.read<OrderCubit>().loadOrders(hotelId);
            context.read<BillingCubit>().loadBillingData(hotelId: hotelId);
            context.read<UserCubit>().loadUsers(hotelId);
            context.read<RoomCubit>().loadRooms(hotelId);
            context.read<IncidentCubit>().loadIncidents(hotelId);
            context.read<ChecklistCubit>().loadChecklists(hotelId);
            context.read<PurchaseOrderCubit>().loadPurchaseOrders(hotelId);
            context.read<VendorCubit>().loadVendors(hotelId);

            // Event Management
            final eventCubit = context.read<EventCubit>();
            eventCubit.setHotelId(hotelId);
            eventCubit.streamHalls();
            eventCubit.streamEvents();
            eventCubit.streamMenuItems();
            eventCubit.streamVendors();
            eventCubit.fetchEventTaxRules();

            // Inventory
            context.read<InventoryCubit>().loadInventory(hotelId);
            context.read<PurchaseOrderCubit>().loadPurchaseOrders(hotelId);
            context.read<VendorCubit>().loadVendors(hotelId);
          }
        }
      },
      child: MaterialApp.router(
        title: 'Hotel Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routerConfig: router,
      ),
    );
  }
}
