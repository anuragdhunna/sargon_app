import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';
import 'package:hotel_manager/features/orders/data/order_model.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';

class OrderTakingScreen extends StatefulWidget {
  const OrderTakingScreen({super.key});

  static const String routeName = '/order';

  @override
  State<OrderTakingScreen> createState() => _OrderTakingScreenState();
}

class _OrderTakingScreenState extends State<OrderTakingScreen> {
  // Mock Menu
  final List<MenuItem> _menu = [
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
  ];

  final Map<MenuItem, int> _cart = {};
  String? _selectedTable;
  String? _selectedRoom;
  String _orderType = 'Table'; // Table or Room

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Order Details Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        name: 'orderType',
                        label: 'Order Type',
                        initialValue: _orderType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Table',
                            child: Text('Dine-in (Table)'),
                          ),
                          DropdownMenuItem(
                            value: 'Room',
                            child: Text('In-Room Dining'),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _orderType = val!;
                            _selectedTable = null;
                            _selectedRoom = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _orderType == 'Table'
                          ? AppDropdown<String>(
                              name: 'tableNumber',
                              label: 'Table Number',
                              items: List.generate(20, (index) {
                                final tableNum = (index + 1).toString();
                                return DropdownMenuItem(
                                  value: tableNum,
                                  child: Text('Table $tableNum'),
                                );
                              }),
                              onChanged: (val) =>
                                  setState(() => _selectedTable = val),
                            )
                          : AppDropdown<String>(
                              name: 'roomNumber',
                              label: 'Room Number',
                              items: List.generate(10, (index) {
                                final roomNum = (101 + index).toString();
                                return DropdownMenuItem(
                                  value: roomNum,
                                  child: Text('Room $roomNum'),
                                );
                              }),
                              onChanged: (val) =>
                                  setState(() => _selectedRoom = val),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Category Filter (Horizontal Scroll)
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: MenuCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name.toUpperCase()),
                    onSelected: (val) {},
                  ),
                );
              }).toList(),
            ),
          ),

          // Menu Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted aspect ratio
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                final qty = _cart[item] ?? 0;

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section - Reduced size
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 32, // Smaller icon
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${item.price}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (qty == 0)
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _cart[item] = 1;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Add'),
                                  ),
                                )
                              else
                                Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (qty > 1) {
                                              _cart[item] = qty - 1;
                                            } else {
                                              _cart.remove(item);
                                            }
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                        ),
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            _cart[item] = qty + 1;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Cart Summary Bottom Sheet
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_cart.length} Items',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total: ₹${_cart.entries.map((e) => e.key.price * e.value).fold(0.0, (a, b) => a + b)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Send to Kitchen',
                      onPressed: () {
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

                        final order = Order(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          tableNumber: _orderType == 'Table'
                              ? _selectedTable!
                              : 'Room $_selectedRoom',
                          items: _cart.entries
                              .expand((e) => List.filled(e.value, e.key))
                              .toList(),
                          status: OrderStatus.pending,
                          timestamp: DateTime.now(),
                        );

                        context.read<OrderCubit>().addOrder(order);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order Sent to Kitchen! 👨‍🍳'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _cart.clear();
                          // Keep table/room selected for next order
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
