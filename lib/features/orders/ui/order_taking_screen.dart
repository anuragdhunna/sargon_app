import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_cart_item.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_item_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/billing/ui/billing_screen.dart';
import 'package:hotel_manager/features/orders/ui/order_history_screen.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_state.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/menu_item_card.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_selection_header.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/category_filter_chips.dart';

class OrderTakingScreen extends StatefulWidget {
  final String? tableId;
  final String? roomId;

  const OrderTakingScreen({super.key, this.tableId, this.roomId});

  static const String routeName = '/order';

  @override
  State<OrderTakingScreen> createState() => _OrderTakingScreenState();
}

class _OrderTakingScreenState extends State<OrderTakingScreen> {
  // Mock Menu
  final List<MenuItem> _allMenuItems = [
    const MenuItem(
      id: '1',
      name: 'Butter Chicken',
      description: 'Rich tomato gravy, chicken',
      price: 350.0,
      category: MenuCategory.mainCourse,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '2',
      name: 'Paneer Tikka',
      description: 'Grilled cottage cheese',
      price: 280.0,
      category: MenuCategory.starter,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '3',
      name: 'Dal Makhani',
      description: 'Black lentils, cream',
      price: 220.0,
      category: MenuCategory.mainCourse,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '4',
      name: 'Mojito',
      description: 'Rum, mint, lime, soda',
      price: 450.0,
      category: MenuCategory.alcohol,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '5',
      name: 'Gulab Jamun',
      description: 'Sweet dumplings',
      price: 120.0,
      category: MenuCategory.dessert,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '6',
      name: 'Chicken Biryani',
      description: 'Aromatic rice with chicken',
      price: 400.0,
      category: MenuCategory.mainCourse,
      imageUrl: 'https://picsum.photos/200/300',
    ),
    const MenuItem(
      id: '7',
      name: 'Masala Chai',
      description: 'Spiced Indian tea',
      price: 50.0,
      category: MenuCategory.drink,
      imageUrl: 'https://picsum.photos/200/300',
    ),
  ];

  // State
  List<MenuItem> _filteredItems = [];
  final List<OrderItem> _cart = [];
  final TextEditingController _orderNotesController = TextEditingController();

  String _searchQuery = '';
  MenuCategory? _selectedCategory;

  String? _selectedTableId;
  String? _selectedRoom;
  String _orderType = 'Table'; // Table or Room
  int _paxCount = 1;
  Customer? _selectedCustomer;
  final OrderPriority _priority = OrderPriority.normal;

  @override
  void initState() {
    super.initState();
    _filteredItems = _allMenuItems;

    // Pre-select if provided
    if (widget.tableId != null) {
      _selectedTableId = widget.tableId;
      _orderType = 'Table';
    } else if (widget.roomId != null) {
      _selectedRoom = widget.roomId;
      _orderType = 'Room';
    }

    // Ensure tables and rooms are loaded for selection
    context.read<TableCubit>().loadTables();
    context.read<RoomCubit>().loadRooms();
  }

  @override
  void dispose() {
    _orderNotesController.dispose();
    super.dispose();
  }

  void _filterMenu() {
    setState(() {
      _filteredItems = _allMenuItems.where((item) {
        final matchesSearch =
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _selectedCategory == null || item.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _addToCart(
    MenuItem item,
    int quantity,
    String? notes,
    CourseType course,
  ) {
    setState(() {
      final existingIndex = _cart.indexWhere(
        (i) =>
            i.menuItemId == item.id && i.notes == notes && i.course == course,
      );
      if (existingIndex != -1) {
        _cart[existingIndex] = _cart[existingIndex].copyWith(
          quantity: _cart[existingIndex].quantity + quantity,
        );
      } else {
        _cart.add(
          OrderItem.fromMenuItem(
            item,
            quantity: quantity,
            notes: notes,
            course: course,
          ),
        );
      }
    });
  }

  void _removeFromCart(OrderItem item) {
    setState(() {
      _cart.remove(item);
    });
  }

  double get _totalAmount =>
      _cart.fold(0, (sum, item) => sum + item.totalPrice);

  int get _totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('New Order'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppDesign.headlineSmall.copyWith(
          color: AppDesign.neutral900,
        ),
        iconTheme: const IconThemeData(color: AppDesign.neutral900),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push(OrderHistoryScreen.routeName);
            },
            tooltip: 'Order History',
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<TableCubit, TableState>(
            builder: (context, tableState) {
              final tables = tableState is TableLoaded
                  ? tableState.tables
                  : <TableEntity>[];

              return BlocBuilder<RoomCubit, RoomState>(
                builder: (context, roomState) {
                  String? guestName;
                  if (_orderType == 'Room' &&
                      _selectedRoom != null &&
                      roomState is RoomLoaded) {
                    final room = roomState.rooms.firstWhere(
                      (r) => r.roomNumber == _selectedRoom,
                      orElse: () => roomState.rooms.first,
                    );
                    final booking = roomState.activeBookings[room.id];
                    guestName = booking?.guestName;
                  }

                  return Column(
                    children: [
                      OrderSelectionHeader(
                        orderType: _orderType,
                        selectedTableId: _selectedTableId,
                        selectedRoom: _selectedRoom,
                        paxCount: _paxCount,
                        tables: tables,
                        onOrderTypeChanged: (val) {
                          setState(() {
                            _orderType = val;
                            _selectedTableId = null;
                            _selectedRoom = null;
                          });
                        },
                        onTableChanged: (val) =>
                            setState(() => _selectedTableId = val),
                        onRoomChanged: (val) =>
                            setState(() => _selectedRoom = val),
                        onPaxChanged: (val) => setState(() => _paxCount = val),
                        onCustomerChanged: (customer) =>
                            setState(() => _selectedCustomer = customer),
                        selectedCustomer: _selectedCustomer,
                        onSearch: (val) {
                          _searchQuery = val;
                          _filterMenu();
                        },
                      ),
                      if (guestName != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesign.primaryStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppDesign.primaryStart,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Guest: $guestName',
                                  style: AppDesign.bodyMedium.copyWith(
                                    color: AppDesign.primaryStart,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),

          // Categories
          CategoryFilterChips(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _filterMenu();
              });
            },
          ),

          // Menu Grid
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppDesign.neutral400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: AppDesign.bodyLarge.copyWith(
                            color: AppDesign.neutral500,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // 5 items on wide screens, 3 on tablets, 2 on phones
                      final crossAxisCount = constraints.maxWidth > 1200
                          ? 5
                          : (constraints.maxWidth > 600 ? 3 : 2);

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.88, // Reduced extra height
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return MenuItemCard(
                            item: item,
                            onTap: () => _showAddToOrderDialog(item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCartSheet,
              backgroundColor: AppDesign.primaryStart,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '$_totalItems Items • ₹${_totalAmount.toStringAsFixed(0)}',
              ),
            )
          : null,
    );
  }

  void _showAddToOrderDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => OrderItemDialog(
        item: item,
        onConfirm: (quantity, notes, course) {
          _addToCart(item, quantity, notes, course);
        },
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Edit button for whole order (waiter can add more items)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add More Items'),
                  onPressed: () {
                    Navigator.pop(context);
                    // Re-open the menu to add more items without clearing cart
                  },
                ),
              ),
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppDesign.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Order',
                      style: AppDesign.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Edit order button (available while status is pending)
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Order'),
                          onPressed: () {
                            // Open a dialog to modify notes/quantity of existing items
                            // For simplicity we just close sheet; items can be edited via per-item edit icons.
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Items List & Notes Section
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Order Notes (Optional)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sticky_note_2,
                                size: 18,
                                color: AppDesign.neutral600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Order Notes (Optional)',
                                style: AppDesign.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppDesign.neutral700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _orderNotesController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Spicy, No Onions, Extra Napkins',
                              hintStyle: AppDesign.bodyMedium.copyWith(
                                color: AppDesign.neutral400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppDesign.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppDesign.neutral200,
                                ),
                              ),
                              filled: true,
                              fillColor: AppDesign.neutral50,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 2,
                            style: AppDesign.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    Text(
                      'Order Items',
                      style: AppDesign.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppDesign.neutral800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_cart.length, (index) {
                      final item = _cart[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeFromCart(item),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red.shade700,
                            ),
                          ),
                          child: OrderCartItem(
                            item: item,
                            canEdit: true,
                            onEdit: () => _editCartItem(index),
                            onRemove: () => _removeFromCart(item),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 100), // Extra space for footer
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppDesign.titleLarge),
                          Text(
                            '₹$_totalAmount',
                            style: AppDesign.headlineSmall.copyWith(
                              color: AppDesign.primaryStart,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedTableId != null || _selectedRoom != null)
                        BlocBuilder<OrderCubit, OrderState>(
                          builder: (context, state) {
                            if (state is OrderLoaded) {
                              final tableId = _orderType == 'Table'
                                  ? _selectedTableId!
                                  : 'room_$_selectedRoom';
                              final existingOrders = state.orders
                                  .where(
                                    (o) =>
                                        o.tableId == tableId &&
                                        o.paymentStatus != PaymentStatus.paid,
                                  )
                                  .toList();

                              if (existingOrders.isNotEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PremiumButton.secondary(
                                    label: 'Review & Generate Bill',
                                    isFullWidth: true,
                                    onPressed: () {
                                      String tableNumber = _orderType == 'Table'
                                          ? 'Table $_selectedTableId'
                                          : 'Room $_selectedRoom';
                                      context.push(
                                        '${BillingScreen.routeName}?tableId=$tableId&tableNumber=$tableNumber',
                                        extra: existingOrders,
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      PremiumButton.primary(
                        label: 'Place Order',
                        isFullWidth: true,
                        onPressed: () async {
                          if (_orderType != 'Takeaway' &&
                              _selectedTableId == null &&
                              _selectedRoom == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a Table or Room'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final String tableId = _orderType == 'Table'
                              ? _selectedTableId!
                              : (_orderType == 'Room'
                                    ? 'room_$_selectedRoom'
                                    : 'takeaway_${DateTime.now().millisecondsSinceEpoch}');

                          String tableNumber = '';
                          if (_orderType == 'Table') {
                            tableNumber =
                                (context.read<TableCubit>().state
                                        as TableLoaded)
                                    .tables
                                    .firstWhere((t) => t.id == _selectedTableId)
                                    .tableCode;
                          } else if (_orderType == 'Room') {
                            tableNumber = 'Room $_selectedRoom';
                          } else {
                            tableNumber = 'Takeaway';
                          }

                          final cubit = context.read<OrderCubit>();
                          final existingOrders = cubit.getOrdersForTable(
                            tableId,
                          );
                          final hasActiveOrder = existingOrders.any(
                            (o) =>
                                o.status == OrderStatus.pending ||
                                o.status == OrderStatus.cooking ||
                                o.status == OrderStatus.ready,
                          );

                          bool shouldProceed = true;
                          if (hasActiveOrder) {
                            shouldProceed =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.merge_type,
                                          color: AppDesign.primaryStart,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('Merge Order?'),
                                      ],
                                    ),
                                    content: Text(
                                      'There is already an active order for $tableNumber. Would you like to add these items to the existing order?',
                                      style: AppDesign.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      PremiumButton.primary(
                                        label: 'Merge Order',
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          }

                          if (!shouldProceed) return;

                          String? guestName;
                          String? roomId;
                          String? bookingId;
                          final roomState = context.read<RoomCubit>().state;
                          if (_orderType == 'Room' &&
                              _selectedRoom != null &&
                              roomState is RoomLoaded) {
                            final room = roomState.rooms.firstWhere(
                              (r) => r.roomNumber == _selectedRoom,
                              orElse: () => roomState.rooms.first,
                            );
                            roomId = room.id;
                            final activeBooking =
                                roomState.activeBookings[room.id];
                            guestName = activeBooking?.guestName;
                            bookingId = activeBooking?.id;
                          }

                          final order = Order(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            tableId: tableId,
                            tableNumber: tableNumber,
                            items: List.from(_cart),
                            status: OrderStatus.pending,
                            timestamp: DateTime.now(),
                            paxCount: _paxCount,
                            priority: _priority,
                            guestName: guestName ?? _selectedCustomer?.name,
                            phone: _selectedCustomer?.phone,
                            customerId: _selectedCustomer?.id,
                            roomId: roomId,
                            bookingId: bookingId,
                            paymentMethod: PaymentMethod
                                .cash, // Default, will be updated in Bill
                            paymentStatus: PaymentStatus.pending,
                            orderNotes:
                                _orderNotesController.text.trim().isEmpty
                                ? null
                                : _orderNotesController.text.trim(),
                          );

                          // Add order to backend (will auto-merge if pending order exists)
                          cubit.addOrder(order);

                          Navigator.pop(context); // Close sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                hasActiveOrder
                                    ? 'Items added to existing order! 👨‍🍳'
                                    : 'Order sent to kitchen! 👨‍🍳',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Clear cart after successful order placement
                          setState(() {
                            _cart.clear();
                            _orderNotesController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCartItem(int index) {
    final item = _cart[index];
    int quantity = item.quantity;
    final notesController = TextEditingController(text: item.notes);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Text('Edit ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (quantity > 1) setDialogState(() => quantity--);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$quantity',
                    style: AppDesign.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setDialogState(() => quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Notes field
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g., Less spicy, no onions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppDesign.neutral50,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            PremiumButton.primary(
              label: 'Update',
              onPressed: () {
                // Update the cart item
                setState(() {
                  _cart[index] = item.copyWith(
                    quantity: quantity,
                    notes: Optional(
                      notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
