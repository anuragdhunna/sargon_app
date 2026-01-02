import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:hotel_manager/features/rooms/ui/booking_details_dialog.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  static const String routeName = '/booking-history';

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoomId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Booking History'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Guest Name or Phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<RoomCubit, RoomState>(
                  builder: (context, state) {
                    if (state is RoomLoaded) {
                      final rooms = state.rooms;
                      return SizedBox(
                        width: 140,
                        child: AppDropdown<String>(
                          name: 'room_filter',
                          label: 'Filter Room',
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Rooms'),
                            ),
                            ...rooms.map(
                              (r) => DropdownMenuItem(
                                value: r.id,
                                child: Text('Room ${r.roomNumber}'),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedRoomId = val),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: BlocBuilder<RoomCubit, RoomState>(
              builder: (context, state) {
                if (state is RoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RoomLoaded) {
                  final filteredBookings = state.allBookings.where((b) {
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch =
                        b.guestName.toLowerCase().contains(query) ||
                        b.guestPhone.contains(query);
                    final matchesRoom =
                        _selectedRoomId == null || b.roomId == _selectedRoomId;
                    return matchesSearch && matchesRoom;
                  }).toList();

                  if (filteredBookings.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history,
                      title: 'No Bookings Found',
                      message: 'Try a different search or filter.',
                    );
                  }

                  // Sort by creation date descending
                  filteredBookings.sort(
                    (a, b) => b.createdAt.compareTo(a.createdAt),
                  );

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _BookingHistoryCard(booking: booking);
                    },
                  );
                }
                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final Booking booking;

  const _BookingHistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AppCard(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BookingDetailsDialog(booking: booking),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.primaryStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.roomId.replaceAll('room_', ''),
                    style: AppDesign.titleLarge.copyWith(
                      color: AppDesign.primaryStart,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ROOM',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.guestName,
                    style: AppDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: AppDesign.neutral600),
                      const SizedBox(width: 4),
                      Text(
                        booking.guestPhone,
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppDesign.neutral600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}',
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${booking.totalAmount.toStringAsFixed(0)}',
                  style: AppDesign.titleMedium.copyWith(
                    color: AppDesign.primaryStart,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _StatusChip(status: booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatus.confirmed:
        color = Colors.blue;
        break;
      case BookingStatus.checkedIn:
        color = Colors.green;
        break;
      case BookingStatus.checkedOut:
        color = Colors.grey;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
