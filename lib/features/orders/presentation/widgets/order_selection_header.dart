import 'package:flutter/material.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/component/inputs/premium_search_bar.dart';

/// Header widget for table/room selection and menu search
class OrderSelectionHeader extends StatelessWidget {
  final String orderType;
  final String? selectedTable;
  final String? selectedRoom;
  final ValueChanged<String> onOrderTypeChanged;
  final ValueChanged<String?> onTableChanged;
  final ValueChanged<String?> onRoomChanged;
  final ValueChanged<String> onSearch;

  const OrderSelectionHeader({
    super.key,
    required this.orderType,
    required this.selectedTable,
    required this.selectedRoom,
    required this.onOrderTypeChanged,
    required this.onTableChanged,
    required this.onRoomChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selection Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppDropdown<String>(
                  name: 'orderType',
                  label: 'Type*',
                  initialValue: orderType,
                  items: const [
                    DropdownMenuItem(value: 'Table', child: Text('Dine-in')),
                    DropdownMenuItem(value: 'Room', child: Text('In-Room')),
                  ],
                  onChanged: (val) => onOrderTypeChanged(val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: orderType == 'Table'
                    ? AppDropdown<String>(
                        name: 'tableNumber',
                        label: 'Table No.*',
                        items: List.generate(20, (index) {
                          final tableNum = (index + 1).toString();
                          return DropdownMenuItem(
                            value: tableNum,
                            child: Text('Table $tableNum'),
                          );
                        }),
                        onChanged: onTableChanged,
                      )
                    : AppDropdown<String>(
                        name: 'roomNumber',
                        label: 'Room No.*',
                        items: List.generate(10, (index) {
                          final roomNum = (101 + index).toString();
                          return DropdownMenuItem(
                            value: roomNum,
                            child: Text('Room $roomNum'),
                          );
                        }),
                        onChanged: onRoomChanged,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          PremiumSearchBar(
            hintText: 'Search menu items...',
            onSearch: onSearch,
          ),
        ],
      ),
    );
  }
}
