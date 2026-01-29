import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';

enum OrderTakingStatus { initial, loading, ready, submitting, success, error }

class OrderTakingState extends Equatable {
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredItems;
  final List<OrderItem> cart;
  final OrderTakingStatus status;
  final String? errorMessage;

  // Selection state
  final String orderType;
  final String? selectedTableId;
  final String? selectedRoom;
  final int paxCount;
  final Customer? selectedCustomer;

  // Filter state
  final String searchQuery;
  final MenuCategory? selectedCategory;

  const OrderTakingState({
    this.allMenuItems = const [],
    this.filteredItems = const [],
    this.cart = const [],
    this.status = OrderTakingStatus.initial,
    this.errorMessage,
    this.orderType = 'Table',
    this.selectedTableId,
    this.selectedRoom,
    this.paxCount = 1,
    this.selectedCustomer,
    this.searchQuery = '',
    this.selectedCategory,
  });

  OrderTakingState copyWith({
    List<MenuItem>? allMenuItems,
    List<MenuItem>? filteredItems,
    List<OrderItem>? cart,
    OrderTakingStatus? status,
    String? errorMessage,
    String? orderType,
    String? selectedTableId,
    String? selectedRoom,
    int? paxCount,
    Customer? selectedCustomer,
    String? searchQuery,
    MenuCategory? selectedCategory,
  }) {
    return OrderTakingState(
      allMenuItems: allMenuItems ?? this.allMenuItems,
      filteredItems: filteredItems ?? this.filteredItems,
      cart: cart ?? this.cart,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      orderType: orderType ?? this.orderType,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      paxCount: paxCount ?? this.paxCount,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  double get totalAmount => cart.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
    allMenuItems,
    filteredItems,
    cart,
    status,
    errorMessage,
    orderType,
    selectedTableId,
    selectedRoom,
    paxCount,
    selectedCustomer,
    searchQuery,
    selectedCategory,
  ];
}
