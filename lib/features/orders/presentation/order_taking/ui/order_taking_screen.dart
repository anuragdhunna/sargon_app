import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/features/orders/ui/order_history_screen.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_cubit.dart';
import 'package:hotel_manager/features/table_mgmt/logic/table_state.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_item_dialog.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_selection_header.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/category_filter_chips.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';

import '../cubit/order_taking_cubit.dart';
import '../cubit/order_taking_state.dart';
import '../widgets/order_menu_grid.dart';
import '../widgets/order_taking_cart_sheet.dart';
import '../widgets/order_guest_info.dart';
import '../widgets/order_taking_fab.dart';

class OrderTakingScreen extends StatefulWidget {
  final String? tableId;
  final String? roomId;

  const OrderTakingScreen({super.key, this.tableId, this.roomId});

  static const String routeName = '/order';

  @override
  State<OrderTakingScreen> createState() => _OrderTakingScreenState();
}

class _OrderTakingScreenState extends State<OrderTakingScreen> {
  final TextEditingController _orderNotesController = TextEditingController();

  // Mock Menu - In real app, this would come from a MenuCubit or Repository
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

  @override
  void initState() {
    super.initState();
    // Initialize data
    context.read<TableCubit>().loadTables();
    context.read<RoomCubit>().loadRooms();
  }

  @override
  void dispose() {
    _orderNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderTakingCubit(
        initialTableId: widget.tableId,
        initialRoomId: widget.roomId,
      )..setMenuItems(_allMenuItems),
      child: BlocBuilder<OrderTakingCubit, OrderTakingState>(
        builder: (context, state) {
          final cubit = context.read<OrderTakingCubit>();

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
                  onPressed: () => context.push(OrderHistoryScreen.routeName),
                  tooltip: 'Order History',
                ),
              ],
            ),
            body: Column(
              children: [
                _buildHeader(cubit, state),
                CategoryFilterChips(
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: cubit.updateCategory,
                ),
                Expanded(
                  child: OrderMenuGrid(
                    items: state.filteredItems,
                    onItemTap: (item) =>
                        _showAddToOrderDialog(context, cubit, item),
                  ),
                ),
              ],
            ),
            floatingActionButton: state.cart.isNotEmpty
                ? OrderTakingFAB(
                    totalItems: state.totalItems,
                    totalAmount: state.totalAmount,
                    onPressed: () => _showCartSheet(context, cubit),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderTakingCubit cubit, OrderTakingState state) {
    return BlocBuilder<TableCubit, TableState>(
      builder: (context, tableState) {
        final tables = tableState is TableLoaded
            ? tableState.tables
            : <TableEntity>[];

        return BlocBuilder<RoomCubit, RoomState>(
          builder: (context, roomState) {
            String? guestName;
            if (state.orderType == 'Room' &&
                state.selectedRoom != null &&
                roomState is RoomLoaded) {
              final room = roomState.rooms.firstWhere(
                (r) => r.roomNumber == state.selectedRoom,
                orElse: () => roomState.rooms.first,
              );
              final booking = roomState.activeBookings[room.id];
              guestName = booking?.guestName;
            }

            return Column(
              children: [
                OrderSelectionHeader(
                  orderType: state.orderType,
                  selectedTableId: state.selectedTableId,
                  selectedRoom: state.selectedRoom,
                  paxCount: state.paxCount,
                  tables: tables,
                  onOrderTypeChanged: cubit.updateOrderType,
                  onTableChanged: cubit.updateTable,
                  onRoomChanged: cubit.updateRoom,
                  onPaxChanged: cubit.updatePax,
                  onCustomerChanged: cubit.updateCustomer,
                  selectedCustomer: state.selectedCustomer,
                  onSearch: cubit.updateSearchQuery,
                ),
                if (guestName != null) OrderGuestInfo(guestName: guestName),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddToOrderDialog(
    BuildContext context,
    OrderTakingCubit cubit,
    MenuItem item,
  ) {
    showDialog(
      context: context,
      builder: (_) => OrderItemDialog(
        item: item,
        onConfirm: (quantity, notes, course) {
          cubit.addToCart(item, quantity, notes, course);
        },
      ),
    );
  }

  void _showCartSheet(BuildContext context, OrderTakingCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => BlocProvider.value(
          value: cubit,
          child: BlocBuilder<OrderTakingCubit, OrderTakingState>(
            builder: (context, state) {
              return OrderTakingCartSheet(
                scrollController: controller,
                cart: state.cart,
                orderNotesController: _orderNotesController,
                totalAmount: state.totalAmount,
                orderType: state.orderType,
                selectedTableId: state.selectedTableId,
                selectedRoom: state.selectedRoom,
                paxCount: state.paxCount,
                selectedCustomer: state.selectedCustomer,
                onEditItem: (index) => _editCartItem(context, cubit, index),
                onRemoveItem: cubit.removeFromCart,
                onPlaceOrder: () => _handlePlaceOrder(context, cubit),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    OrderTakingCubit cubit,
  ) async {
    final state = cubit.state;

    if (state.orderType != 'Takeaway' &&
        state.selectedTableId == null &&
        state.selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Table or Room'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare table details
    final String tableId = state.orderType == 'Table'
        ? state.selectedTableId!
        : (state.orderType == 'Room'
              ? 'room_${state.selectedRoom}'
              : 'takeaway_${DateTime.now().millisecondsSinceEpoch}');

    String tableNumber = '';
    if (state.orderType == 'Table') {
      tableNumber = (context.read<TableCubit>().state as TableLoaded).tables
          .firstWhere((t) => t.id == state.selectedTableId)
          .tableCode;
    } else if (state.orderType == 'Room') {
      tableNumber = 'Room ${state.selectedRoom}';
    } else {
      tableNumber = 'Takeaway';
    }

    // Merge Check
    final orderCubit = context.read<OrderCubit>();
    final existingOrders = orderCubit.getOrdersForTable(tableId);
    final hasActiveOrder = existingOrders.any(
      (o) =>
          o.status != OrderStatus.served &&
          o.status != OrderStatus.cancelled &&
          o.paymentStatus != PaymentStatus.paid,
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
                  Icon(Icons.merge_type, color: AppDesign.primaryStart),
                  const SizedBox(width: 12),
                  const Text('Merge Order?'),
                ],
              ),
              content: Text(
                'Add these items to the existing order for $tableNumber?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                PremiumButton.primary(
                  label: 'Merge Order',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (!shouldProceed) return;

    // Room info
    String? guestName;
    String? roomId;
    String? bookingId;
    final roomState = context.read<RoomCubit>().state;
    if (state.orderType == 'Room' &&
        state.selectedRoom != null &&
        roomState is RoomLoaded) {
      final room = roomState.rooms.firstWhere(
        (r) => r.roomNumber == state.selectedRoom,
      );
      roomId = room.id;
      final activeBooking = roomState.activeBookings[room.id];
      guestName = activeBooking?.guestName;
      bookingId = activeBooking?.id;
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableId: tableId,
      tableNumber: tableNumber,
      items: List.from(state.cart),
      status: OrderStatus.pending,
      timestamp: DateTime.now(),
      paxCount: state.paxCount,
      priority: OrderPriority.normal,
      guestName: guestName ?? state.selectedCustomer?.name,
      phone: state.selectedCustomer?.phone,
      customerId: state.selectedCustomer?.id,
      roomId: roomId,
      bookingId: bookingId,
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.pending,
      orderNotes: _orderNotesController.text.trim().isEmpty
          ? null
          : _orderNotesController.text.trim(),
    );

    orderCubit.addOrder(order);

    if (mounted) {
      Navigator.pop(context); // Close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasActiveOrder ? 'Items added! 👨‍🍳' : 'Order sent! 👨‍🍳',
          ),
          backgroundColor: Colors.green,
        ),
      );
      cubit.clearCart();
      _orderNotesController.clear();
    }
  }

  void _editCartItem(BuildContext context, OrderTakingCubit cubit, int index) {
    final item = cubit.state.cart[index];
    int quantity = item.quantity;
    final notesController = TextEditingController(text: item.notes);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Text('Edit ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                cubit.updateCartItem(
                  index,
                  quantity,
                  notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
