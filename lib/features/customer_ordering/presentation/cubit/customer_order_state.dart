import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';

enum CustomerOrderStatus { initial, loading, ready, submitting, success, error }

class CustomerOrderState extends Equatable {
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredItems;
  final List<OrderItem> cart;
  final CustomerOrderStatus status;
  final String? errorMessage;
  final String hotelId;
  final String? selectedTableId;
  final int paxCount;
  final String searchQuery;
  final MenuCategory? selectedCategory;
  final String? placedOrderId; // ID of the order just placed

  const CustomerOrderState({
    this.allMenuItems = const [],
    this.filteredItems = const [],
    this.cart = const [],
    this.status = CustomerOrderStatus.initial,
    this.errorMessage,
    required this.hotelId,
    this.selectedTableId,
    this.paxCount = 1,
    this.searchQuery = '',
    this.selectedCategory,
    this.placedOrderId,
  });

  CustomerOrderState copyWith({
    List<MenuItem>? allMenuItems,
    List<MenuItem>? filteredItems,
    List<OrderItem>? cart,
    CustomerOrderStatus? status,
    String? errorMessage,
    String? hotelId,
    String? selectedTableId,
    int? paxCount,
    String? searchQuery,
    MenuCategory? selectedCategory,
    String? placedOrderId,
  }) {
    return CustomerOrderState(
      allMenuItems: allMenuItems ?? this.allMenuItems,
      filteredItems: filteredItems ?? this.filteredItems,
      cart: cart ?? this.cart,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hotelId: hotelId ?? this.hotelId,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      paxCount: paxCount ?? this.paxCount,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      placedOrderId: placedOrderId ?? this.placedOrderId,
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
    hotelId,
    selectedTableId,
    paxCount,
    searchQuery,
    selectedCategory,
    placedOrderId,
  ];
}