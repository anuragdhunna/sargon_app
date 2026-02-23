import 'package:hotel_manager/core/app/app_bootstrap.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/notification_service.dart';
import 'package:hotel_manager/core/services/storage/secure_storage_service.dart';
import 'package:hotel_manager/core/services/session/session_service.dart';
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
import 'package:hotel_manager/features/staff_mgmt/logic/owner_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/owner_registration_cubit.dart';
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

class AppProviders extends StatelessWidget {
  final AppBootstrapResult bootstrap;
  final Widget child;

  const AppProviders({super.key, required this.bootstrap, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SecureStorageService>.value(
          value: bootstrap.secureStorage,
        ),
        RepositoryProvider<SessionService>.value(
          value: bootstrap.sessionService,
        ),
        RepositoryProvider<AuthService>.value(value: bootstrap.authService),
        RepositoryProvider<DatabaseService>.value(
          value: bootstrap.databaseService,
        ),
        RepositoryProvider<RoomRepository>(
          create: (context) =>
              RoomRepository(databaseService: bootstrap.databaseService),
        ),
        RepositoryProvider<OfferRepository>(
          create: (context) =>
              OfferRepositoryImpl(databaseService: bootstrap.databaseService),
        ),
        RepositoryProvider<LoyaltyRepository>(
          create: (context) =>
              LoyaltyRepositoryImpl(databaseService: bootstrap.databaseService),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(
            databaseService: bootstrap.databaseService,
            auditService: AuditService(),
          ),
        ),
        RepositoryProvider<StockManagerService>(
          create: (context) => StockManagerService(bootstrap.databaseService),
        ),
        RepositoryProvider<INotificationRepository>(
          create: (context) => NotificationRepository(
            service: NotificationService(
              databaseService: bootstrap.databaseService,
            ),
          ),
        ),
        RepositoryProvider<EventRepository>(
          create: (context) => EventRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: bootstrap.authCubit),
          BlocProvider<ChecklistCubit>.value(value: bootstrap.checklistCubit),
          BlocProvider<TableCubit>.value(value: bootstrap.tableCubit),
          BlocProvider<EventCubit>(
            create: (context) => EventCubit(context.read<EventRepository>()),
          ),
          BlocProvider<UserCubit>(
            create: (context) =>
                UserCubit(databaseService: bootstrap.databaseService),
          ),
          BlocProvider<OrderCubit>(
            create: (context) => OrderCubit(
              databaseService: bootstrap.databaseService,
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
                IncidentCubit(databaseService: bootstrap.databaseService),
          ),
          BlocProvider<PerformanceCubit>(
            create: (context) => PerformanceCubit(),
          ),
          BlocProvider<RoomCubit>(
            create: (context) => RoomCubit(
              repository: context.read<RoomRepository>(),
              checklistCubit: bootstrap.checklistCubit,
            ),
          ),
          BlocProvider<CustomerCubit>(
            create: (context) =>
                CustomerCubit(databaseService: bootstrap.databaseService),
          ),
          BlocProvider<BillingCubit>(
            create: (context) =>
                BillingCubit(databaseService: bootstrap.databaseService),
          ),
          BlocProvider<OfferCubit>(
            create: (context) => OfferCubit(
              offerRepository: context.read<OfferRepository>(),
            )..loadOffers('hotel_1'), // TODO: Use actual hotelId from state
          ),
          BlocProvider<DashboardCubit>(
            create: (context) =>
                DashboardCubit(databaseService: bootstrap.databaseService),
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
          BlocProvider<OwnerCubit>(
            create: (context) =>
                OwnerCubit(databaseService: bootstrap.databaseService),
          ),
          BlocProvider<OwnerRegistrationCubit>(
            create: (context) => OwnerRegistrationCubit(
              authService: bootstrap.authService,
              databaseService: bootstrap.databaseService,
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
