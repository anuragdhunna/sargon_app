import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/data/room_model.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:go_router/go_router.dart';

/// Dialog showing details of an occupied room
class GuestDetailsDialog extends StatelessWidget {
  final Room room;
  final Booking booking;

  const GuestDetailsDialog({
    super.key,
    required this.room,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest Details',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Room ${room.roomNumber} - ${room.type.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoRow(
              Icons.person_outline,
              'Guest Name',
              booking.guestName,
            ),
            _buildInfoRow(Icons.phone, 'Phone', booking.guestPhone),
            if (booking.guestEmail != null)
              _buildInfoRow(Icons.email, 'Email', booking.guestEmail!),

            const Divider(height: 32),

            _buildInfoRow(
              Icons.calendar_today,
              'Check-In',
              _formatDate(booking.checkIn),
            ),
            _buildInfoRow(
              Icons.event,
              'Check-Out',
              _formatDate(booking.checkOut),
            ),
            _buildInfoRow(Icons.nights_stay, 'Nights', '${booking.nights}'),

            const Divider(height: 32),

            _buildInfoRow(
              Icons.payments,
              'Total Amount',
              '₹${booking.totalAmount}',
            ),

            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(booking.status)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(booking.status),
                    color: _getStatusColor(booking.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.status.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (booking.status == BookingStatus.confirmed)
                  TextButton.icon(
                    onPressed: () => _handleCheckIn(context),
                    icon: const Icon(Icons.login),
                    label: const Text('Check In'),
                  ),
                if (booking.status == BookingStatus.checkedIn) ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/folio/${booking.id}');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View Folio'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade800,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _handleCheckOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade800,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.checkedIn:
        return Icons.hotel;
      case BookingStatus.checkedOut:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _handleCheckIn(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    await context.read<RoomCubit>().checkIn(
      bookingId: booking.id,
      roomId: room.id,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${booking.guestName} checked in successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleCheckOut(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    await context.read<RoomCubit>().checkOut(
      bookingId: booking.id,
      roomId: room.id,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${booking.guestName} checked out successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
