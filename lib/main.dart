import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_manager/core/navigation/app_router.dart';
import 'package:hotel_manager/core/services/firebase_service.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/notification_service.dart';
import 'package:hotel_manager/features/attendance/logic/attendance_cubit.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/dashboard/logic/dashboard_cubit.dart';
import 'package:hotel_manager/features/incidents/logic/incident_cubit.dart';
import 'package:hotel_manager/features/inventory/inventory_index.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/performance/logic/performance_cubit.dart';
import 'package:hotel_manager/features/rooms/data/room_repository.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/offers/domain/repositories/offer_repository.dart';
import 'package:hotel_manager/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:hotel_manager/features/offers/logic/offer_cubit.dart';
import 'package:hotel_manager/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:hotel_manager/features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_cubit.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/inventory/logic/stock_manager_service.dart';
import 'package:hotel_manager/features/notifications/data/repositories/notification_repository.dart';
import 'package:hotel_manager/features/notifications/logic/notification_cubit.dart';
import 'package:hotel_manager/features/orders/presentation/order_history/cubit/order_history_cubit.dart';
import 'package:hotel_manager/features/events/data/repositories/event_repository.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';

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

  final authCubit = AuthCubit(authService: authService);
  final checklistCubit = ChecklistCubit(databaseService: databaseService);
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
        RepositoryProvider<OfferRepository>(
          create: (context) =>
              OfferRepositoryImpl(databaseService: databaseService),
        ),
        RepositoryProvider<LoyaltyRepository>(
          create: (context) =>
              LoyaltyRepositoryImpl(databaseService: databaseService),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(
            databaseService: databaseService,
            auditService:
                AuditService(), // AuditService is a singleton/static based on implementation
          ),
        ),
        RepositoryProvider<StockManagerService>(
          create: (context) => StockManagerService(databaseService),
        ),
        RepositoryProvider<INotificationRepository>(
          create: (context) => NotificationRepository(
            service: NotificationService(databaseService: databaseService),
          ),
        ),
        RepositoryProvider<EventRepository>(
          create: (context) => EventRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ChecklistCubit>(create: (context) => checklistCubit),
          BlocProvider<EventCubit>(
            create: (context) => EventCubit(context.read<EventRepository>()),
          ),
          BlocProvider<UserCubit>(
            create: (context) => UserCubit(databaseService: databaseService),
          ),
          BlocProvider<OrderCubit>(
            create: (context) => OrderCubit(
              databaseService: databaseService,
              offerRepository: context.read<OfferRepository>(),
              stockManagerService: context.read<StockManagerService>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                InventoryCubit(repository: InventoryRepository()),
          ),
          BlocProvider(
            create: (context) => PurchaseOrderCubit(
              repository: InventoryRepository(),
              notificationRepository: context.read<INotificationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => VendorCubit(repository: InventoryRepository()),
          ),
          BlocProvider(
            create: (context) => GoodsReceiptCubit(
              inventoryCubit: context.read<InventoryCubit>(),
              purchaseOrderCubit: context.read<PurchaseOrderCubit>(),
              repository: InventoryRepository(),
            ),
          ),
          BlocProvider<AttendanceCubit>(create: (context) => AttendanceCubit()),
          BlocProvider<IncidentCubit>(
            create: (context) =>
                IncidentCubit(databaseService: databaseService),
          ),
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
          BlocProvider<OfferCubit>(
            create: (context) => OfferCubit(
              offerRepository: context.read<OfferRepository>(),
            )..loadOffers('hotel_1'), // TODO: Use actual hotelId from state
          ),
          BlocProvider<DashboardCubit>(
            create: (context) =>
                DashboardCubit(databaseService: databaseService),
          ),
          BlocProvider<LoyaltyCubit>(
            create: (context) =>
                LoyaltyCubit(
                  loyaltyRepository: context.read<LoyaltyRepository>(),
                )..loadLoyaltyData(
                  'hotel_1',
                ), // TODO: Use actual hotelId from state
          ),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              notificationRepository: context.read<INotificationRepository>(),
            ),
          ),
          BlocProvider<OrderHistoryCubit>(
            create: (context) => OrderHistoryCubit(),
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
