import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_manager/core/navigation/app_router.dart';
import 'package:hotel_manager/core/services/firebase_service.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/attendance/logic/attendance_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/incidents/logic/incident_cubit.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_cubit.dart';
import 'package:hotel_manager/features/inventory/purchase_orders/logic/purchase_order_cubit.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
import 'package:hotel_manager/features/inventory/vendors/logic/vendor_cubit.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/performance/logic/performance_cubit.dart';
import 'package:hotel_manager/features/rooms/data/room_repository.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Create services
  final authService = AuthService();
  final databaseService = DatabaseService();

  // Enable offline persistence for mobile
  databaseService.enableOfflinePersistence();

  // Initialize Services
  AuditService.init(databaseService);

  // Create cubits
  final authCubit = AuthCubit(authService: authService);
  final checklistCubit = ChecklistCubit();
  final inventoryCubit = InventoryCubit();
  final purchaseOrderCubit = PurchaseOrderCubit();
  final vendorCubit = VendorCubit();
  final tableCubit = TableCubit(databaseService: databaseService);

  // Create router with auth cubit for refresh
  final router = createRouter(authCubit);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<DatabaseService>.value(value: databaseService),
        RepositoryProvider<RoomRepository>(
          create: (context) => RoomRepository(databaseService: databaseService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ChecklistCubit>(create: (context) => checklistCubit),
          BlocProvider<UserCubit>(
            create: (context) => UserCubit(databaseService: databaseService),
          ),
          BlocProvider<OrderCubit>(
            create: (context) => OrderCubit(databaseService: databaseService),
          ),
          BlocProvider<InventoryCubit>(create: (context) => inventoryCubit),
          BlocProvider<PurchaseOrderCubit>(
            create: (context) => purchaseOrderCubit,
          ),
          BlocProvider<VendorCubit>(create: (context) => vendorCubit),
          BlocProvider<GoodsReceiptCubit>(
            create: (context) => GoodsReceiptCubit(
              inventoryCubit: inventoryCubit,
              purchaseOrderCubit: purchaseOrderCubit,
            ),
          ),
          BlocProvider<AttendanceCubit>(create: (context) => AttendanceCubit()),
          BlocProvider<IncidentCubit>(create: (context) => IncidentCubit()),
          BlocProvider<PerformanceCubit>(
            create: (context) => PerformanceCubit(),
          ),
          BlocProvider<RoomCubit>(
            create: (context) => RoomCubit(
              repository: context.read<RoomRepository>(),
              checklistCubit: checklistCubit,
            ),
          ),
          BlocProvider<CustomerCubit>(
            create: (context) =>
                CustomerCubit(databaseService: databaseService),
          ),
          BlocProvider<TableCubit>.value(value: tableCubit),
          BlocProvider<BillingCubit>(
            create: (context) => BillingCubit(databaseService: databaseService),
          ),
        ],
        child: HotelManagerApp(router: router),
      ),
    ),
  );
}

class HotelManagerApp extends StatelessWidget {
  final GoRouter router;

  const HotelManagerApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthVerified) {
          // Small delay to allow Firebase Auth token to propagate to Database instance
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.read<TableCubit>().loadTables();
              context.read<OrderCubit>().loadOrders();
              context.read<BillingCubit>().loadBillingData();
              context.read<UserCubit>().loadUsers();
              context.read<RoomCubit>().loadRooms();
            }
          });
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
