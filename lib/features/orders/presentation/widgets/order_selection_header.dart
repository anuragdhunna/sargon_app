import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../component/inputs/app_dropdown.dart';
import '../../../../component/inputs/app_text_field.dart';
import '../../../../features/rooms/logic/room_cubit.dart';
import '../../../../component/inputs/premium_search_bar.dart';
import '../../../../core/models/models.dart';
import '../../../../theme/app_design.dart';
import '../../../../features/staff_mgmt/ui/widgets/customer_selection_sheet.dart';

/// Header widget for table/room selection and menu search with Pax intelligence
class OrderSelectionHeader extends StatelessWidget {
  final String orderType;
  final String? selectedTableId;
  final String? selectedRoom;
  final int paxCount;
  final List<TableEntity> tables;
  final ValueChanged<String> onOrderTypeChanged;
  final ValueChanged<String?> onTableChanged;
  final ValueChanged<String?> onRoomChanged;
  final ValueChanged<int> onPaxChanged;
  final ValueChanged<String> onSearch;
  final Customer? selectedCustomer;
  final ValueChanged<Customer?> onCustomerChanged;

  const OrderSelectionHeader({
    super.key,
    required this.orderType,
    required this.selectedTableId,
    required this.selectedRoom,
    required this.paxCount,
    required this.tables,
    required this.onOrderTypeChanged,
    required this.onTableChanged,
    required this.onRoomChanged,
    required this.onPaxChanged,
    required this.onSearch,
    this.selectedCustomer,
    required this.onCustomerChanged,
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
          // Pax & Type Selection Row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AppTextField(
                  name: 'pax',
                  label: 'Pax',
                  prefixIcon: Icons.people,
                  initialValue: paxCount.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final pax = int.tryParse(val ?? '1') ?? 1;
                    onPaxChanged(pax);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppDropdown<String>(
                  name: 'orderType',
                  label: 'Type*',
                  initialValue: orderType,
                  items: const [
                    DropdownMenuItem(value: 'Table', child: Text('Dine-in')),
                    DropdownMenuItem(value: 'Room', child: Text('In-Room')),
                    DropdownMenuItem(
                      value: 'Takeaway',
                      child: Text('Takeaway'),
                    ),
                  ],
                  onChanged: (val) => onOrderTypeChanged(val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: orderType == 'Table'
                    ? _buildTableDropdown()
                    : (orderType == 'Room'
                          ? _buildRoomDropdown(context)
                          : _buildTakeawayHeader(context)),
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

  Widget _buildTableDropdown() {
    final availableTables = tables
        .where(
          (t) => t.status == TableStatus.available || t.id == selectedTableId,
        )
        .toList();

    // Sort tables so suggested ones (fit for pax) come first
    availableTables.sort((a, b) {
      bool aFits = a.minCapacity <= paxCount && a.maxCapacity >= paxCount;
      bool bFits = b.minCapacity <= paxCount && b.maxCapacity >= paxCount;
      if (aFits && !bFits) return -1;
      if (!aFits && bFits) return 1;
      return a.tableCode.compareTo(b.tableCode);
    });

    return AppDropdown<String>(
      name: 'tableId',
      label: 'Table No.*',
      initialValue: selectedTableId,
      items: availableTables.map((t) {
        bool fits = t.minCapacity <= paxCount && t.maxCapacity >= paxCount;
        return DropdownMenuItem(
          value: t.id,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.tableCode),
              if (fits)
                const Icon(Icons.star, size: 12, color: Colors.orange)
              else
                Text(
                  '(${t.maxCapacity})',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: onTableChanged,
    );
  }

  Widget _buildRoomDropdown(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        if (state is! RoomLoaded) {
          return const AppDropdown<String>(
            name: 'room_loading',
            label: 'Room No.*',
            items: [],
          );
        }

        // Only show rooms that are currently occupied
        final occupiedRooms = state.rooms.where((r) {
          final booking = state.activeBookings[r.id];
          return booking?.status == BookingStatus.checkedIn;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdown<String>(
              name: 'roomNumber',
              label: 'Room No.*',
              initialValue: selectedRoom,
              items: occupiedRooms.map((r) {
                return DropdownMenuItem(
                  value: r.roomNumber,
                  child: Text('Room ${r.roomNumber}'),
                );
              }).toList(),
              onChanged: onRoomChanged,
            ),
            if (selectedRoom != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppDesign.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      'Guest: ${state.activeBookings[state.rooms.firstWhere((r) => r.roomNumber == selectedRoom).id]?.guestName ?? "Unknown"}',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTakeawayHeader(BuildContext context) {
    return InkWell(
      onTap: () => _showCustomerSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selectedCustomer != null
              ? AppDesign.primaryStart.withOpacity(0.05)
              : AppDesign.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCustomer != null
                ? AppDesign.primaryStart
                : AppDesign.neutral300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selectedCustomer != null
                  ? Icons.person
                  : Icons.shopping_bag_outlined,
              size: 20,
              color: selectedCustomer != null
                  ? AppDesign.primaryStart
                  : AppDesign.neutral600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCustomer?.name ?? 'Select Customer*',
                style: AppDesign.bodyMedium.copyWith(
                  color: selectedCustomer != null
                      ? AppDesign.primaryStart
                      : AppDesign.neutral700,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSheet(BuildContext context) {
    CustomerSelectionSheet.show(
      context,
      initialCustomer: selectedCustomer,
      onSelected: onCustomerChanged,
    );
  }
}
