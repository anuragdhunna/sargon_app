import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/action_button.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/dialogs/confirmation_dialog.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/data/room_model.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/rooms/ui/booking_history_screen.dart';
import 'package:hotel_manager/features/rooms/ui/create_booking_dialog.dart';
import 'package:hotel_manager/features/rooms/ui/guest_details_dialog.dart';
import 'package:hotel_manager/theme/app_design.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  static const String routeName = '/rooms';

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  RoomType? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load rooms on init
    context.read<RoomCubit>().loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          BlocBuilder<RoomCubit, RoomState>(
            builder: (context, state) {
              if (state is! RoomLoaded) return const SizedBox.shrink();

              return ActionButton.add(
                tooltip: 'Quick Booking',
                onPressed: () {
                  final filteredRooms = _filterRooms(state.rooms);
                  final availableRooms = filteredRooms
                      .where((r) => r.status == RoomStatus.available)
                      .toList();
                  if (availableRooms.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<RoomCubit>(),
                        child: CreateBookingDialog(room: availableRooms.first),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No available rooms in selected category',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppDesign.primaryStart),
            onPressed: () => _showRoomsGuide(context),
            tooltip: 'How to use Rooms',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push(BookingHistoryScreen.routeName),
            tooltip: 'Booking History',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RoomInitial || state is RoomLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoomError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<RoomCubit>().loadRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! RoomLoaded) {
            return const Center(child: Text('Unknown state'));
          }

          final allRooms = state.rooms;
          final bookings = state.activeBookings;
          final filteredRooms = context.read<RoomCubit>().getFilteredRooms();

          return Column(
            children: [
              // Date Filters
              _buildDateFilters(),
              const Divider(height: 1),

              // Category Filter Bar
              _buildCategoryFilter(allRooms),
              const Divider(height: 1),

              // Room Status Legend
              _buildStatusLegend(filteredRooms),

              // Room Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      final booking = bookings[room.id];

                      return _RoomCard(
                        room: room,
                        booking: booking,
                        onTap: () => _handleRoomClick(room, booking),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateFilters() {
    return BlocBuilder<RoomCubit, RoomState>(
      builder: (context, state) {
        if (state is! RoomLoaded) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppDesign.neutral500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange:
                          state.filterFrom != null && state.filterTo != null
                          ? DateTimeRange(
                              start: state.filterFrom!,
                              end: state.filterTo!,
                            )
                          : null,
                      builder: (context, child) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 550,
                            ),
                            child: child,
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<RoomCubit>().setFilters(
                        from: picked.start,
                        to: picked.end,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 18,
                        color: AppDesign.primaryStart,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.filterFrom == null
                            ? 'Select Dates'
                            : '${state.filterFrom!.day}/${state.filterFrom!.month} - ${state.filterTo!.day}/${state.filterTo!.month}',
                        style: AppDesign.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: 'Select dates to check availability',
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppDesign.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Text('Available Only', style: AppDesign.bodySmall),
                  Switch(
                    value: state.availableOnly,
                    onChanged: (val) {
                      context.read<RoomCubit>().setFilters(availableOnly: val);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Room> _filterRooms(List<Room> rooms) {
    if (_selectedCategory == null) return rooms;
    return rooms.where((r) => r.type == _selectedCategory).toList();
  }

  Widget _buildCategoryFilter(List<Room> allRooms) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text('All Rooms (${allRooms.length})'),
              selected: _selectedCategory == null,
              onSelected: (selected) =>
                  setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 8),

            ...RoomType.values.map((type) {
              final count = allRooms.where((r) => r.type == type).length;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(type.icon, size: 18),
                  label: Text('${type.displayName} ($count)'),
                  selected: _selectedCategory == type,
                  onSelected: (selected) => setState(
                    () => _selectedCategory = selected ? type : null,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegend(List<Room> filteredRooms) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: RoomStatus.values.map((status) {
          final count = filteredRooms.where((r) => r.status == status).length;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${status.displayName} ($count)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _handleRoomClick(Room room, Booking? booking) {
    if (room.status == RoomStatus.occupied && booking != null) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<RoomCubit>(),
          child: GuestDetailsDialog(room: room, booking: booking),
        ),
      );
    } else if (room.status == RoomStatus.reserved && booking != null) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<RoomCubit>(),
          child: GuestDetailsDialog(room: room, booking: booking),
        ),
      );
    } else if (room.status == RoomStatus.cleaning) {
      _showCleaningConfirmation(room);
    } else if (room.status == RoomStatus.available) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<RoomCubit>(),
          child: CreateBookingDialog(room: room),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Room ${room.roomNumber} is currently ${room.status.displayName}',
          ),
        ),
      );
    }
  }

  void _showCleaningConfirmation(Room room) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => ConfirmationDialog(
            title: 'Mark Room as Cleaned?',
            message:
                'Room ${room.roomNumber} will be marked as available for new bookings.',
            confirmText: 'Mark as Cleaned',
            icon: const Icon(
              Icons.cleaning_services,
              size: 48,
              color: Colors.green,
            ),
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthVerified) {
        context.read<RoomCubit>().updateRoomStatus(
          roomId: room.id,
          newStatus: RoomStatus.available,
          userId: authState.userId,
          userName: authState.userName,
          userRole: authState.role.name,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Room ${room.roomNumber} marked as Available'),
              backgroundColor: AppDesign.success,
            ),
          );
        }
      }
    }
  }

  void _showRoomsGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Management Guide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Legend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildGuideItem(RoomStatus.available, 'Ready for new guests.'),
              _buildGuideItem(
                RoomStatus.occupied,
                'Guest stayed in, checking folio enabled.',
              ),
              _buildGuideItem(
                RoomStatus.cleaning,
                'Needs housekeeping attention.',
              ),
              _buildGuideItem(
                RoomStatus.reserved,
                'Booking confirmed, waiting for check-in.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Click an Available room to Create Booking.',
                style: TextStyle(height: 1.5),
              ),
              const Text(
                '• Click Occupied/Reserved to View Guest Details.',
                style: TextStyle(height: 1.5),
              ),
              const Text(
                '• Use the History icon to view old bookings.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(RoomStatus status, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${status.displayName}: $description',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final Booking? booking;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            border: Border.all(color: room.status.color, width: 2),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(room.type.icon, size: 24, color: room.status.color),
              const SizedBox(height: 6),
              Text(
                room.roomNumber,
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: room.status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                  border: Border.all(color: room.status.color, width: 1),
                ),
                child: Text(
                  room.status == RoomStatus.available
                      ? room.type.displayName.substring(0, 1)
                      : room.status.displayName.substring(0, 3).toUpperCase(),
                  style: AppDesign.labelSmall.copyWith(
                    color: room.status.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (booking != null) ...[
                const SizedBox(height: 4),
                Text(
                  booking!.guestName.split(' ').first,
                  style: AppDesign.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
