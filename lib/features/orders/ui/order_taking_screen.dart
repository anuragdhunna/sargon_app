import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';
import 'package:hotel_manager/features/orders/data/order_model.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_cart_item.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_item_dialog.dart';
import 'package:hotel_manager/features/orders/ui/order_history_screen.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/menu_item_card.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/order_selection_header.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/category_filter_chips.dart';
import 'package:go_router/go_router.dart';

class OrderTakingScreen extends StatefulWidget {
  const OrderTakingScreen({super.key});

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
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '2',
      name: 'Paneer Tikka',
      description: 'Grilled cottage cheese',
      price: 280.0,
      category: MenuCategory.starter,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '3',
      name: 'Dal Makhani',
      description: 'Black lentils, cream',
      price: 220.0,
      category: MenuCategory.mainCourse,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '4',
      name: 'Mojito',
      description: 'Rum, mint, lime, soda',
      price: 450.0,
      category: MenuCategory.alcohol,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '5',
      name: 'Gulab Jamun',
      description: 'Sweet dumplings',
      price: 120.0,
      category: MenuCategory.dessert,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '6',
      name: 'Chicken Biryani',
      description: 'Aromatic rice with chicken',
      price: 400.0,
      category: MenuCategory.mainCourse,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    const MenuItem(
      id: '7',
      name: 'Masala Chai',
      description: 'Spiced Indian tea',
      price: 50.0,
      category: MenuCategory.drink,
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  // State
  List<MenuItem> _filteredItems = [];
  final List<MenuItem> _cart = [];
  final TextEditingController _orderNotesController = TextEditingController();

  String _searchQuery = '';
  MenuCategory? _selectedCategory;

  String? _selectedTable;
  String? _selectedRoom;
  String _orderType = 'Table'; // Table or Room

  @override
  void initState() {
    super.initState();
    _filteredItems = _allMenuItems;
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

  void _addToCart(MenuItem item, int quantity, String? notes) {
    setState(() {
      for (int i = 0; i < quantity; i++) {
        _cart.add(item.copyWith(notes: notes));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFromCart(MenuItem item) {
    setState(() {
      _cart.remove(item);
    });
  }

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + item.price);

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
          // Top Section: Table/Room Selection & Search
          OrderSelectionHeader(
            orderType: _orderType,
            selectedTable: _selectedTable,
            selectedRoom: _selectedRoom,
            onOrderTypeChanged: (val) {
              setState(() {
                _orderType = val;
                _selectedTable = null;
                _selectedRoom = null;
              });
            },
            onTableChanged: (val) => setState(() => _selectedTable = val),
            onRoomChanged: (val) => setState(() => _selectedRoom = val),
            onSearch: (val) {
              _searchQuery = val;
              _filterMenu();
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
              label: Text('${_cart.length} Items • ₹$_totalAmount'),
            )
          : null,
    );
  }

  void _showAddToOrderDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => OrderItemDialog(
        item: item,
        onConfirm: (quantity, notes) {
          _addToCart(item, quantity, notes);
        },
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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

            // Overall Order Notes Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppDesign.neutral50,
                border: Border(
                  bottom: BorderSide(color: AppDesign.neutral200, width: 1),
                ),
              ),
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: _orderNotesController,
                    decoration: InputDecoration(
                      hintText:
                          'e.g., Birthday celebration, Rush order, Table setup request',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppDesign.neutral300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppDesign.neutral300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: 2,
                    style: AppDesign.bodyMedium,
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeFromCart(item),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.shade100,
                      child: Icon(Icons.delete, color: Colors.red.shade700),
                    ),
                    child: OrderCartItem(
                      item: item,
                      canEdit: true,
                      onEdit: () => _editCartItem(index),
                      onRemove: () => _removeFromCart(item),
                    ),
                  );
                },
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
                    PremiumButton.primary(
                      label: 'Place Order',
                      isFullWidth: true,
                      onPressed: () async {
                        if (_selectedTable == null && _selectedRoom == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a Table or Room number',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final tableNumber = _orderType == 'Table'
                            ? _selectedTable!
                            : 'Room $_selectedRoom';

                        // Check if there's already a pending order for this table
                        final cubit = context.read<OrderCubit>();
                        final existingOrders = cubit.getOrdersForTable(
                          tableNumber,
                        );
                        final hasPendingOrder = existingOrders.any(
                          (o) => o.status == OrderStatus.pending,
                        );

                        bool shouldProceed = true;
                        if (hasPendingOrder) {
                          // Show confirmation dialog
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
                                    'There is already a pending order for $tableNumber. Would you like to add these items to the existing order?',
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

                        final order = Order(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          tableNumber: tableNumber,
                          items: List.from(_cart),
                          status: OrderStatus.pending,
                          timestamp: DateTime.now(),
                          orderNotes: _orderNotesController.text.trim().isEmpty
                              ? null
                              : _orderNotesController.text.trim(),
                        );

                        // Add order to backend (will auto-merge if pending order exists)
                        cubit.addOrder(order);

                        Navigator.pop(context); // Close sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              hasPendingOrder
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
    );
  }

  void _editCartItem(int index) {
    final item = _cart[index];
    int quantity = 1;
    final notesController = TextEditingController(text: item.notes);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                      if (quantity > 1) setState(() => quantity--);
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
                    onPressed: () => setState(() => quantity++),
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
                setState(() {
                  // Remove old instances of this item (same id & old notes)
                  _cart.removeWhere(
                    (i) => i.id == item.id && i.notes == item.notes,
                  );
                  // Add the edited version the requested number of times
                  for (int i = 0; i < quantity; i++) {
                    _cart.add(
                      item.copyWith(notes: notesController.text.trim()),
                    );
                  }
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
