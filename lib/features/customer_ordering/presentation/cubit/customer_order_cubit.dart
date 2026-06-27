import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/offers/domain/repositories/offer_repository.dart';
import 'package:hotel_manager/features/offers/logic/happy_hour_service.dart';
import 'customer_order_state.dart';

class CustomerOrderCubit extends Cubit<CustomerOrderState> {
  final SettingsRepository _settingsRepository;
  final DatabaseService _databaseService;
  final OfferRepository _offerRepository;
  StreamSubscription? _menuSubscription;
  List<HappyHour> _happyHours = [];
  StreamSubscription? _hhSubscription;

  CustomerOrderCubit({
    required SettingsRepository settingsRepository,
    required DatabaseService databaseService,
    required OfferRepository offerRepository,
    required String hotelId,
    String? initialTableId,
  }) : _settingsRepository = settingsRepository,
       _databaseService = databaseService,
       _offerRepository = offerRepository,
       super(CustomerOrderState(
         hotelId: hotelId,
         selectedTableId: initialTableId,
       )) {
    _loadMenuItems(hotelId);
    _loadHappyHours(hotelId);
  }

  void _loadMenuItems(String hotelId) {
    _menuSubscription = _settingsRepository.streamMenuItems(hotelId).listen((
      items,
    ) {
      setMenuItems(items);
    });
  }

  void _loadHappyHours(String hotelId) {
    _hhSubscription = _offerRepository.watchHappyHours(hotelId).listen((hh) {
      _happyHours = hh;
    });
  }

  @override
  Future<void> close() {
    _menuSubscription?.cancel();
    _hhSubscription?.cancel();
    return super.close();
  }

  void setMenuItems(List<MenuItem> items) {
    emit(
      state.copyWith(
        allMenuItems: items,
        filteredItems: _getFilteredList(
          items,
          state.searchQuery,
          state.selectedCategory,
        ),
        status: CustomerOrderStatus.ready,
      ),
    );
  }

  void updateSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredItems: _getFilteredList(
          state.allMenuItems,
          query,
          state.selectedCategory,
        ),
      ),
    );
  }

  void updateCategory(MenuCategory? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        filteredItems: _getFilteredList(
          state.allMenuItems,
          state.searchQuery,
          category,
        ),
      ),
    );
  }

  void updateTable(String? tableId) {
    emit(state.copyWith(selectedTableId: tableId));
  }

  void updatePax(int pax) {
    emit(state.copyWith(paxCount: pax));
  }

  void addToCart(
    MenuItem item,
    int quantity,
    String? notes,
    CourseType course,
  ) {
    final cart = List<OrderItem>.from(state.cart);
    final existingIndex = cart.indexWhere(
      (i) => i.menuItemId == item.id && i.notes == notes && i.course == course,
    );

    if (existingIndex != -1) {
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity,
      );
    } else {
      cart.add(
        OrderItem.fromMenuItem(
          item,
          quantity: quantity,
          notes: notes,
          course: course,
        ),
      );
    }
    emit(state.copyWith(cart: cart));
  }

  void removeFromCart(OrderItem item) {
    final cart = state.cart.where((i) => i != item).toList();
    emit(state.copyWith(cart: cart));
  }

  void updateCartItem(int index, int quantity, String? notes) {
    final cart = List<OrderItem>.from(state.cart);
    if (index >= 0 && index < cart.length) {
      cart[index] = cart[index].copyWith(
        quantity: quantity,
        notes: Optional(notes),
      );
      emit(state.copyWith(cart: cart));
    }
  }

  void clearCart() {
    emit(state.copyWith(cart: const []));
  }

  Future<void> placeOrder() async {
    if (state.cart.isEmpty) {
      emit(state.copyWith(
        status: CustomerOrderStatus.error,
        errorMessage: 'Cart is empty',
      ));
      return;
    }

    emit(state.copyWith(status: CustomerOrderStatus.submitting));

    try {
      // Process items: apply happy hour and auto-fire starters/drinks
      final processedItems = await Future.wait(
        state.cart.map((item) async {
          var updatedItem = item;

          // Happy Hour Check
          if (item.discountAmount == 0 && !item.isComplimentary) {
            final menuItem = await _databaseService.getMenuItem(
              state.hotelId,
              item.menuItemId,
            );
            if (menuItem != null) {
              final hh = HappyHourService.getActiveHappyHour(
                _happyHours,
                menuItem,
                DateTime.now(),
              );
              updatedItem = HappyHourService.applyHappyHour(updatedItem, hh);
            }
          }

          // Auto-fire starters and drinks for new items
          if (updatedItem.kdsStatus == KdsStatus.pending &&
              (updatedItem.course == CourseType.starters ||
                  updatedItem.course == CourseType.drinks)) {
            updatedItem = updatedItem.copyWith(
              kdsStatus: KdsStatus.fired,
              firedAt: Optional(DateTime.now()),
            );
          }

          return updatedItem;
        }),
      );

      // Create the order
      final order = Order(
        id: '',
        hotelId: state.hotelId,
        tableId: state.selectedTableId ?? 'walk_in', // TODO: Handle walk-in/table-less orders
        tableNumber: state.selectedTableId ?? 'Walk-in',
        items: processedItems,
        status: OrderStatus.pending,
        openedAt: DateTime.now(),
        paxCount: state.paxCount,
        priority: OrderPriority.normal,
        orderNotes: null, // TODO: Add overall order notes from UI
        waiterName: null, // Customer order, no waiter
        bookingId: null,
        roomId: null,
        guestName: null,
        customerId: null,
        phone: null,
        paymentMethod: null,
        paymentStatus: PaymentStatus.pending,
        appliedOfferId: null,
        appliedOfferName: null,
        createdBy: 'customer', // TODO: Possibly use a customer ID or device ID
        createdOn: DateTime.now(),
        updatedBy: 'customer',
        updatedOn: DateTime.now(),
        isDeleted: false,
      );

      // Save the order (this will generate an ID)
      await _databaseService.saveOrder(order);

      // Update table status to occupied if a table is selected
      if (state.selectedTableId != null) {
        await _databaseService.updateTableStatus(
          state.hotelId,
          state.selectedTableId!,
          TableStatus.occupied,
        );
      }

      emit(state.copyWith(
        status: CustomerOrderStatus.success,
        placedOrderId: order.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerOrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  List<MenuItem> _getFilteredList(
    List<MenuItem> items,
    String query,
    MenuCategory? category,
  ) {
    return items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || item.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}