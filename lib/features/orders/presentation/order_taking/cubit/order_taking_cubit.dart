import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'order_taking_state.dart';

class OrderTakingCubit extends Cubit<OrderTakingState> {
  OrderTakingCubit({String? initialTableId, String? initialRoomId})
    : super(
        OrderTakingState(
          selectedTableId: initialTableId,
          selectedRoom: initialRoomId,
          orderType: initialRoomId != null ? 'Room' : 'Table',
        ),
      );

  void setMenuItems(List<MenuItem> items) {
    emit(
      state.copyWith(
        allMenuItems: items,
        filteredItems: _getFilteredList(
          items,
          state.searchQuery,
          state.selectedCategory,
        ),
        status: OrderTakingStatus.ready,
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

  void updateOrderType(String type) {
    emit(
      state.copyWith(
        orderType: type,
        selectedTableId: null,
        selectedRoom: null,
      ),
    );
  }

  void updateTable(String? tableId) {
    emit(state.copyWith(selectedTableId: tableId));
  }

  void updateRoom(String? roomId) {
    emit(state.copyWith(selectedRoom: roomId));
  }

  void updatePax(int pax) {
    emit(state.copyWith(paxCount: pax));
  }

  void updateCustomer(Customer? customer) {
    emit(state.copyWith(selectedCustomer: customer));
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
