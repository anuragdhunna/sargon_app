import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/action_button.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/data/room_model.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/rooms/ui/create_booking_dialog.dart';
import 'package:hotel_manager/features/rooms/ui/guest_details_dialog.dart';

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
                  final availableRooms = filteredRooms.where((r) => r.status == RoomStatus.available).toList();
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
                      const SnackBar(content: Text('No available rooms in selected category')),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
          final bookings = state.bookings;
          final filteredRooms = _filterRooms(allRooms);

          return Column(
            children: [
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  List<Room> _filterRooms(List<Room> rooms) {
    return _selectedCategory == null
        ? rooms
        : rooms.where((r) => r.type == _selectedCategory).toList();
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
              onSelected: (selected) => setState(() => _selectedCategory = null),
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
                  onSelected: (selected) => setState(() => _selectedCategory = selected ? type : null),
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
          content: Text('Room ${room.roomNumber} is currently ${room.status.displayName}'),
        ),
      );
    }
  }

  void _showCleaningConfirmation(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Room ${room.roomNumber} as Cleaned?'),
        content: const Text('This will make the room available for new bookings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthVerified) {
                context.read<RoomCubit>().updateRoomStatus(
                  roomId: room.id,
                  newStatus: RoomStatus.available,
                  userId: authState.userId,
                  userName: authState.userName,
                  userRole: authState.role.name,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Room ${room.roomNumber} marked as Available'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Mark as Cleaned'),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: room.status.color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                room.type.icon,
                size: 24,
                color: room.status.color,
              ),
              const SizedBox(height: 6),
              Text(
                room.roomNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: room.status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: room.status.color, width: 1),
                ),
                child: Text(
                  room.status == RoomStatus.available
                      ? room.type.displayName.substring(0, 1)
                      : room.status.displayName.substring(0, 3).toUpperCase(),
                  style: TextStyle(
                    color: room.status.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              if (booking != null) ...[
                const SizedBox(height: 4),
                Text(
                  booking!.guestName.split(' ').first,
                  style: const TextStyle(fontSize: 10),
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
