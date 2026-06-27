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

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<void> saveOrder(Order order) => Future.value();

  @override
  Future<MenuItem?> getMenuItem(String hotelId, String itemId) =>
      Future.value(null);

  @override
  Future<void> updateTableStatus(
      String hotelId, String tableId, TableStatus status) =>
      Future.value();
}

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
  late CustomerOrderCubit customerOrderCubit;

  setUpAll(() {
    registerFallbackValue(FakeMenuItem());
    registerFallbackValue(FakeHappyHour());
    registerFallbackValue(FakeOrderItem());
    registerFallbackValue(FakeOrder());
  });

  setUp(() {
    settingsRepository = MockSettingsRepository();
    databaseService = MockDatabaseService();
    offerRepository = MockOfferRepository();

    // Default mock behavior
    when(
      () => settingsRepository.streamMenuItems('test-hotel'),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => offerRepository.watchHappyHours('test-hotel'),
    ).thenAnswer((_) => Stream.value([]));
    when(() => databaseService.getMenuItem(any(), any()))
    .thenAnswer((_) async => null);
  when(() => databaseService.saveOrder(any())).thenAnswer((_) async => {});
  when(
    () => databaseService.updateTableStatus(any(), any(), any()),
  ).thenAnswer((_) async => {});

    customerOrderCubit = CustomerOrderCubit(
      settingsRepository: settingsRepository,
      databaseService: databaseService,
      offerRepository: offerRepository,
      hotelId: 'test-hotel',
      initialTableId: 'table-1',
    );
  });

  tearDown(() {
    customerOrderCubit.close();
  });

  group('CustomerOrderCubit Tests', () {
    test('initial state is CustomerOrderState with initial status', () {
      expect(
        customerOrderCubit.state.status,
        equals(CustomerOrderStatus.initial),
      );
      expect(customerOrderCubit.state.hotelId, equals('test-hotel'));
      expect(customerOrderCubit.state.selectedTableId, equals('table-1'));
    });

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      '_loadMenuItems emits ready state when menu items are loaded',
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
        return customerOrderCubit;
      },
      act: (cubit) => cubit, // Load happens in constructor
      expect: () => [
        isA<CustomerOrderState>(),
        isA<CustomerOrderState>().having(
          (state) => state.status,
          'status',
          equals(CustomerOrderStatus.ready),
        ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      '_loadHappyHours loads happy hours',
      build: () {
        final testHappyHours = [
          HappyHour(
            id: 'hh-1',
            hotelId: 'test-hotel',
            name: 'Test HH',
            applicableDays: ['Monday'],
            startTime: '10:00',
            endTime: '11:00',
            discountType: DiscountType.percent,
            discountValue: 50,
            autoApply: true,
            isActive: true,
            priority: 1,
          ),
        ];
        when(
          () => offerRepository.watchHappyHours(any()),
        ).thenAnswer((_) => Stream.value(testHappyHours));
        return customerOrderCubit;
      },
      act: (cubit) => cubit, // Load happens in constructor
      expect: () => [
        isA<CustomerOrderState>().having(
          (s) => s.status,
          'status',
          equals(CustomerOrderStatus.ready),
        ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateSearchQuery updates searchQuery and filters items',
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
        return customerOrderCubit;
      },
      act: (cubit) => cubit.updateSearchQuery('test'),
      expect: () => [
        isA<CustomerOrderState>()
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
        ];
        when(
          () => settingsRepository.streamMenuItems(any()),
        ).thenAnswer((_) => Stream.value(testMenuItems));
        return customerOrderCubit;
      },
      act: (cubit) => cubit.updateCategory(MenuCategory.drink),
      expect: () => [
        isA<CustomerOrderState>()
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
      build: () {
        return customerOrderCubit;
      },
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
      build: () {
        return customerOrderCubit;
      },
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        return customerOrderCubit;
      },
      act: (cubit) => cubit.addToCart(
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
        2,
        'Test notes',
        CourseType.starters,
      ),
      expect: () => [
        isA<CustomerOrderState>()
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

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'addToCart merges existing item with same notes and course',
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        return customerOrderCubit;
      },
      act: (cubit) {
        // Add first item
        cubit.addToCart(
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
          1,
          'Test notes',
          CourseType.starters,
        );
        // Add same item again
        cubit.addToCart(
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
          2,
          'Test notes',
          CourseType.starters,
        );
      },
      expect: () => [
        isA<CustomerOrderState>()
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        return customerOrderCubit;
      },
      act: (cubit) {
        // Add item first
        cubit.addToCart(
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
          1,
          'Test notes',
          CourseType.starters,
        );
        // Then remove it
        cubit.removeFromCart(
          OrderItem.fromMenuItem(
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
            quantity: 1,
            notes: 'Test notes',
            course: CourseType.starters,
          ),
        );
      },
      expect: () => [
        isA<CustomerOrderState>().having(
          (s) => s.cart.length,
          'cart.length',
          equals(0),
        ),
      ],
    );

    blocTest<CustomerOrderCubit, CustomerOrderState>(
      'updateCartItem updates item quantity and notes',
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        return customerOrderCubit;
      },
      act: (cubit) {
        // Add item first
        cubit.addToCart(
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
          1,
          'Original notes',
          CourseType.starters,
        );
        // Then update it
        cubit.updateCartItem(0, 3, 'Updated notes');
      },
      expect: () => [
        isA<CustomerOrderState>()
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        return customerOrderCubit;
      },
      act: (cubit) {
        // Add item first
        cubit.addToCart(
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
          1,
          'Test notes',
          CourseType.starters,
        );
        // Then clear cart
        cubit.clearCart();
      },
      expect: () => [
        isA<CustomerOrderState>().having(
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
        final testHappyHour = HappyHour(
          id: 'hh-1',
          hotelId: 'test-hotel',
          name: 'Test HH',
          applicableDays: ['Monday'],
          startTime: '10:00',
          endTime: '11:00',
          discountType: DiscountType.percent,
          discountValue: 50,
          autoApply: true,
          isActive: true,
          priority: 1,
        );
        when(
          () => settingsRepository.streamMenuItems(any()),
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        when(
          () => offerRepository.watchHappyHours(any()),
        ).thenAnswer((_) => Stream.value([testHappyHour]));
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
        return customerOrderCubit;
      },
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CustomerOrderState>().having(
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
              equals('generated-order-id'),
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
      build: () {
        return customerOrderCubit;
      },
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
        ).thenAnswer((_) => Stream.value([testMenuItem]));
        when(
          () => databaseService.saveOrder(any()),
        ).thenAnswer((_) async => throw Exception('Database error'));
        return customerOrderCubit;
      },
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CustomerOrderState>().having(
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
