import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/offers/domain/repositories/offer_repository.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_cubit.dart';
import 'package:hotel_manager/features/customer_ordering/presentation/cubit/customer_order_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockOfferRepository extends Mock implements OfferRepository {}

class FakeMenuItem extends Fake implements MenuItem {}

class FakeHappyHour extends Fake implements HappyHour {}

class FakeOrderItem extends Fake implements OrderItem {}

class FakeOrder extends Fake implements Order {
  @override
  final String id;

  @override
  final String hotelId;

  @override
  final String tableId;

  @override
  final String tableNumber;

  @override
  final List<OrderItem> items;

  @override
  final OrderStatus status;

  @override
  final DateTime? openedAt;

  @override
  final int paxCount;

  @override
  final OrderPriority priority;

  @override
  final String? orderNotes;

  @override
  final String? waiterName;

  @override
  final String? bookingId;

  @override
  final String? roomId;

  @override
  final String? guestName;

  @override
  final String? customerId;

  @override
  final String? phone;

  @override
  final PaymentMethod? paymentMethod;

  @override
  final PaymentStatus paymentStatus;

  @override
  final String? appliedOfferId;

  @override
  final String? appliedOfferName;

  @override
  final String? createdBy;

  @override
  final DateTime? createdOn;

  @override
  final String? updatedBy;

  @override
  final DateTime? updatedOn;

  @override
  final String? deletedBy;

  @override
  final DateTime? deletedOn;

  @override
  final bool isDeleted;

  FakeOrder({
    this.id = 'fake-order-id',
    this.hotelId = 'test-hotel',
    this.tableId = 'table-1',
    this.tableNumber = '1',
    this.items = const [],
    this.status = OrderStatus.pending,
    this.openedAt,
    this.paxCount = 1,
    this.priority = OrderPriority.normal,
    this.orderNotes,
    this.waiterName,
    this.bookingId,
    this.roomId,
    this.guestName,
    this.customerId,
    this.phone,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.appliedOfferId,
    this.appliedOfferName,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.deletedBy,
    this.deletedOn,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    hotelId,
    tableId,
    tableNumber,
    items,
    status,
    openedAt,
    paxCount,
    priority,
    orderNotes,
    waiterName,
    bookingId,
    roomId,
    guestName,
    customerId,
    phone,
    paymentMethod,
    paymentStatus,
    appliedOfferId,
    appliedOfferName,
    createdBy,
    createdOn,
    updatedBy,
    updatedOn,
    deletedBy,
    deletedOn,
    isDeleted,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          hotelId == other.hotelId &&
          tableId == other.tableId &&
          tableNumber == other.tableNumber &&
          items == other.items &&
          status == other.status &&
          openedAt == other.openedAt &&
          paxCount == other.paxCount &&
          priority == other.priority &&
          orderNotes == other.orderNotes &&
          waiterName == other.waiterName &&
          bookingId == other.bookingId &&
          roomId == other.roomId &&
          guestName == other.guestName &&
          customerId == other.customerId &&
          phone == other.phone &&
          paymentMethod == other.paymentMethod &&
          paymentStatus == other.paymentStatus &&
          appliedOfferId == other.appliedOfferId &&
          appliedOfferName == other.appliedOfferName &&
          createdBy == other.createdBy &&
          createdOn == other.createdOn &&
          updatedBy == other.updatedBy &&
          updatedOn == other.updatedOn &&
          deletedBy == other.deletedBy &&
          deletedOn == other.deletedOn &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      hotelId.hashCode ^
      tableId.hashCode ^
      tableNumber.hashCode ^
      items.hashCode ^
      status.hashCode ^
      openedAt.hashCode ^
      paxCount.hashCode ^
      priority.hashCode ^
      orderNotes.hashCode ^
      waiterName.hashCode ^
      bookingId.hashCode ^
      roomId.hashCode ^
      guestName.hashCode ^
      customerId.hashCode ^
      phone.hashCode ^
      paymentMethod.hashCode ^
      paymentStatus.hashCode ^
      appliedOfferId.hashCode ^
      appliedOfferName.hashCode ^
      createdBy.hashCode ^
      createdOn.hashCode ^
      updatedBy.hashCode ^
      updatedOn.hashCode ^
      deletedBy.hashCode ^
      deletedOn.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'FakeOrder{id: $id, hotelId: $hotelId, tableId: $tableId, tableNumber: $tableNumber, items: $items, status: $status, openedAt: $openedAt, paxCount: $paxCount, priority: $priority, orderNotes: $orderNotes, waiterName: $waiterName, bookingId: $bookingId, roomId: $roomId, guestName: $guestName, customerId: $customerId, phone: $phone, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, appliedOfferId: $appliedOfferId, appliedOfferName: $appliedOfferName, createdBy: $createdBy, createdOn: $createdOn, updatedBy: $updatedBy, updatedOn: $updatedOn, deletedBy: $deletedBy, deletedOn: $deletedOn, isDeleted: $isDeleted}';
  }

  @override
  Map<String, dynamic> toJson() => {};

  factory FakeOrder.fromJson(Map<String, dynamic> json) => FakeOrder();
}

void main() {
  late MockSettingsRepository settingsRepository;
  late MockDatabaseService databaseService;
  late MockOfferRepository offerRepository;

  setUpAll(() {
    registerFallbackValue(FakeMenuItem());
    registerFallbackValue(FakeHappyHour());
    registerFallbackValue(FakeOrderItem());
    registerFallbackValue(FakeOrder());
    registerFallbackValue(TableStatus.available);
  });

  setUp(() {
    settingsRepository = MockSettingsRepository();
    databaseService = MockDatabaseService();
    offerRepository = MockOfferRepository();

    // Default mock behavior: Stream.empty() to prevent constructor auto-emits
    when(
      () => settingsRepository.streamMenuItems(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => offerRepository.watchHappyHours(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(() => databaseService.getMenuItem(any(), any()))
    .thenAnswer((_) async => null);
    when(() => databaseService.saveOrder(any())).thenAnswer((_) async => {});
    when(
      () => databaseService.updateTableStatus(any(), any(), any()),
    ).thenAnswer((_) async => {});
  });

  CustomerOrderCubit createCubit() {
    return CustomerOrderCubit(
      settingsRepository: settingsRepository,
      databaseService: databaseService,
      offerRepository: offerRepository,
      hotelId: 'test-hotel',
      initialTableId: 'table-1',
    );
  }

  group('CustomerOrderCubit Tests', () {
    final testMenuItem = MenuItem(
      id: 'item-1',
      hotelId: 'test-hotel',
      name: 'Test Item',
      description: 'Test Description',
      price: 100.0,
      category: MenuCategory.starter,
      imageUrl: '',
      isAvailable: true,
      dietaryType: DietaryType.veg,
      preparationTimeMinutes: 15,
    );
    test('initial state is CustomerOrderState with initial status', () {
      final cubit = createCubit();
      expect(
        cubit.state.status,
        equals(CustomerOrderStatus.initial),
      );
      expect(cubit.state.hotelId, equals('test-hotel'));
      expect(cubit.state.selectedTableId, equals('table-1'));
      addTearDown(cubit.close);
    });

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'setMenuItems emits ready state when menu items are loaded',
      build: () {
        final testMenuItems = [
          MenuItem(
            id: 'item-1',
            hotelId: 'test-hotel',
            name: 'Test Item',
            description: 'Test Description',
            price: 100.0,
            category: MenuCategory.starter,
            imageUrl: '',
            isAvailable: true,
            dietaryType: DietaryType.veg,
            preparationTimeMinutes: 15,
          ),
        ];
        when(
          () => settingsRepository.streamMenuItems(any()),
        ).thenAnswer((_) => Stream.value(testMenuItems));
        return createCubit();
      },
      act: (cubit) => cubit, // Load happens in constructor
      expect: () => [
        isA<CustomerOrderState>().having(
          (state) => state.status,
          'status',
          equals(CustomerOrderStatus.ready),
        ),
      ],
    );

    test('_loadHappyHours subscribes to watchHappyHours', () {
      when(
        () => offerRepository.watchHappyHours('test-hotel'),
      ).thenAnswer((_) => const Stream.empty());
      final cubit = createCubit();
      verify(() => offerRepository.watchHappyHours('test-hotel')).called(1);
      cubit.close();
    });

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateSearchQuery updates searchQuery and filters items',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.updateSearchQuery('test'),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having((s) => s.searchQuery, 'searchQuery', equals('test'))
            .having(
              (s) => s.filteredItems.length,
              'filteredItems.length',
              equals(1),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateCategory updates selectedCategory and filters items',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [
          testMenuItem,
          MenuItem(
            id: 'item-2',
            hotelId: 'test-hotel',
            name: 'Test Drink',
            description: 'Test Drink Description',
            price: 50.0,
            category: MenuCategory.drink,
            imageUrl: '',
            isAvailable: true,
            dietaryType: DietaryType.veg,
            preparationTimeMinutes: 5,
          ),
        ],
        filteredItems: [testMenuItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.updateCategory(MenuCategory.drink),
      expect: () => [
        isA<CustomerOrderState>()
            .having(
              (s) => s.status,
              'status',
              equals(CustomerOrderStatus.ready),
            )
            .having(
              (s) => s.selectedCategory,
              'selectedCategory',
              equals(MenuCategory.drink),
            )
            .having(
              (s) => s.filteredItems.length,
              'filteredItems.length',
              equals(1),
            )
            .having(
              (s) => s.filteredItems.first.category,
              'filteredItems.first.category',
              equals(MenuCategory.drink),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateTable updates selectedTableId',
      build: createCubit,
      act: (cubit) => cubit.updateTable('table-2'),
      expect: () => [
        isA<CustomerOrderState>().having(
          (s) => s.selectedTableId,
          'selectedTableId',
          equals('table-2'),
        ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updatePax updates paxCount',
      build: createCubit,
      act: (cubit) => cubit.updatePax(4),
      expect: () => [
        isA<CustomerOrderState>().having(
          (s) => s.paxCount,
          'paxCount',
          equals(4),
        ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'addToCart adds item to cart',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.addToCart(
        testMenuItem,
        2,
        'Test notes',
        CourseType.starters,
      ),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having((s) => s.cart.length, 'cart.length', equals(1))
            .having(
              (s) => s.cart.first.quantity,
              'cart.first.quantity',
              equals(2),
            )
            .having(
              (s) => s.cart.first.notes!,
              'cart.first.notes',
              equals('Test notes'),
            ),
      ],
    );

    final testOrderItem = OrderItem.fromMenuItem(
      testMenuItem,
      quantity: 1,
      notes: 'Test notes',
      course: CourseType.starters,
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'addToCart merges existing item with same notes and course',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        cart: [testOrderItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.addToCart(
        testMenuItem,
        2,
        'Test notes',
        CourseType.starters,
      ),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having((s) => s.cart.length, 'cart.length', equals(1))
            .having(
              (s) => s.cart.first.quantity,
              'cart.first.quantity',
              equals(3), // 1 + 2
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'removeFromCart removes item from cart',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        cart: [testOrderItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.removeFromCart(testOrderItem),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having(
              (s) => s.cart.length,
              'cart.length',
              equals(0),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateCartItem updates item quantity and notes',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        cart: [testOrderItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.updateCartItem(0, 3, 'Updated notes'),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having((s) => s.cart.length, 'cart.length', equals(1))
            .having(
              (s) => s.cart.first.quantity,
              'cart.first.quantity',
              equals(3),
            )
            .having(
              (s) => s.cart.first.notes!,
              'cart.first.notes',
              equals('Updated notes'),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'clearCart empties the cart',
      build: createCubit,
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        allMenuItems: [testMenuItem],
        filteredItems: [testMenuItem],
        cart: [testOrderItem],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.clearCart(),
      expect: () => [
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', equals(CustomerOrderStatus.ready))
            .having(
              (s) => s.cart.length,
              'cart.length',
              equals(0),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'placeOrder emits submitting then success when order is placed successfully',
      build: () {
        final testMenuItem = MenuItem(
          id: 'item-1',
          hotelId: 'test-hotel',
          name: 'Test Item',
          description: 'Test Description',
          price: 100.0,
          category: MenuCategory.starter,
          imageUrl: '',
          isAvailable: true,
          dietaryType: DietaryType.veg,
          preparationTimeMinutes: 15,
        );
        when(
          () => settingsRepository.streamMenuItems(any()),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => offerRepository.watchHappyHours(any()),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => databaseService.getMenuItem('test-hotel', 'item-1'),
        ).thenAnswer((_) async => testMenuItem);
        when(() => databaseService.saveOrder(any())).thenAnswer(
          (_) async => Order(
            id: 'generated-order-id',
            hotelId: 'test-hotel',
            tableId: 'table-1',
            tableNumber: '1',
            items: [],
            status: OrderStatus.pending,
          ),
        );
        when(
          () => databaseService.updateTableStatus(any(), any(), any()),
        ).thenAnswer((_) async => {});
        return createCubit();
      },
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        selectedTableId: 'table-1',
        cart: [
          OrderItem(
            id: 'item-1',
            menuItemId: 'item-1',
            name: 'Test Item',
            price: 100.0,
            quantity: 1,
            kdsStatus: KdsStatus.pending,
          ),
        ],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CustomerOrderState>()
            .having(
              (s) => s.status,
              'status',
              equals(CustomerOrderStatus.submitting),
            ),
        isA<CustomerOrderState>()
            .having(
              (s) => s.status,
              'status',
              equals(CustomerOrderStatus.success),
            )
            .having(
              (s) => s.placedOrderId,
              'placedOrderId',
              isNotEmpty,
            ),
      ],
      verify: (_) {
        verify(() => databaseService.saveOrder(any())).called(1);
        verify(
          () => databaseService.updateTableStatus(
            'test-hotel',
            'table-1',
            TableStatus.occupied,
          ),
        ).called(1);
      },
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'placeOrder emits error when cart is empty',
      build: createCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CustomerOrderState>()
            .having(
              (s) => s.status,
              'status',
              equals(CustomerOrderStatus.error),
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              equals('Cart is empty'),
            ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'placeOrder emits error when order saving fails',
      build: () {
        when(
          () => settingsRepository.streamMenuItems(any()),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => databaseService.saveOrder(any()),
        ).thenAnswer((_) async => throw Exception('Database error'));
        return createCubit();
      },
      seed: () => CustomerOrderState(
        hotelId: 'test-hotel',
        selectedTableId: 'table-1',
        cart: [
          OrderItem(
            id: 'item-1',
            menuItemId: 'item-1',
            name: 'Test Item',
            price: 100.0,
            quantity: 1,
            kdsStatus: KdsStatus.pending,
          ),
        ],
        status: CustomerOrderStatus.ready,
      ),
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CustomerOrderState>()
            .having(
              (s) => s.status,
              'status',
              equals(CustomerOrderStatus.submitting),
            ),
        isA<CustomerOrderState>().having(
          (s) => s.status,
          'status',
          equals(CustomerOrderStatus.error),
        ),
      ],
    );
  });
}
