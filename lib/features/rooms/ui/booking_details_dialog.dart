import 'package:flutter/material.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:intl/intl.dart';

class BookingDetailsDialog extends StatelessWidget {
  final Booking booking;

  const BookingDetailsDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');
    final roomNumber = booking.roomId.replaceAll('room_', '');

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID: ${booking.id.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            _DetailItem(
              icon: Icons.meeting_room,
              label: 'Room Number',
              value: 'Room $roomNumber',
            ),
            _DetailItem(
              icon: Icons.person,
              label: 'Guest Name',
              value: booking.guestName,
            ),
            _DetailItem(
              icon: Icons.phone,
              label: 'Guest Phone',
              value: booking.guestPhone,
            ),
            if (booking.guestEmail != null && booking.guestEmail!.isNotEmpty)
              _DetailItem(
                icon: Icons.email,
                label: 'Guest Email',
                value: booking.guestEmail!,
              ),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    icon: Icons.login,
                    label: 'Check In',
                    value: dateFormat.format(booking.checkIn),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    icon: Icons.logout,
                    label: 'Check Out',
                    value: dateFormat.format(booking.checkOut),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    icon: Icons.people,
                    label: 'Guests',
                    value: '${booking.numberOfGuests}',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    icon: Icons.payments,
                    label: 'Total Amount',
                    value: '₹${booking.totalAmount.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            if (booking.paidAmount > 0)
              _DetailItem(
                icon: Icons.check_circle,
                label: 'Advance Paid',
                value:
                    '₹${booking.paidAmount.toStringAsFixed(0)} (${booking.paymentMethod?.displayName ?? 'Cash'})',
                color: Colors.green,
              ),

            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(booking.status)),
                ),
                child: Text(
                  booking.status.name.substring(0, 1).toUpperCase() +
                      booking.status.name.substring(1),
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
