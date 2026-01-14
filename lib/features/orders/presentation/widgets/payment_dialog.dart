import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/component/feedback/custom_snackbar.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';

class PaymentDialog extends StatefulWidget {
  final Bill bill;

  const PaymentDialog({super.key, required this.bill});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _refController = TextEditingController();
  String? _selectedRoomId;
  String? _selectedBookingId;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.remainingBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Payment for Bill #${widget.bill.id.split('_').last}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppDesign.primaryStart.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppDesign.primaryStart,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding Amount',
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                        ),
                      ),
                      Text(
                        '₹${widget.bill.remainingBalance.toStringAsFixed(2)}',
                        style: AppDesign.titleMedium.copyWith(
                          color: AppDesign.primaryStart,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (INR)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.currency_rupee),
                filled: true,
                fillColor: AppDesign.neutral50,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppDesign.neutral50,
              ),
              items: PaymentMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.displayName.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                labelText: 'Reference / Note',
                hintText: 'e.g., Transaction ID, Card digits',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppDesign.neutral50,
              ),
            ),
            if (_selectedMethod == PaymentMethod.bill_to_room) ...[
              const SizedBox(height: 16),
              const Text(
                'Select Guest Room',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RoomCubit, RoomState>(
                builder: (context, roomState) {
                  try {
                    if (roomState is RoomLoaded) {
                      final occupiedRooms = roomState.rooms
                          .where((r) => r.status == RoomStatus.occupied)
                          .toList();

                      if (occupiedRooms.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No occupied rooms found.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }

                      final String? selectedValue = occupiedRooms.any((r) => r.id == _selectedRoomId)
                          ? _selectedRoomId
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedValue,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppDesign.neutral50,
                          hintText: 'Select Room',
                        ),
                        items: occupiedRooms.map((r) {
                          try {
                            // booking may not exist for a room; guard with try/catch
                            Booking? _booking;
                            try {
                              _booking = roomState.allBookings.firstWhere(
                                (b) => b.roomId == r.id && b.status == BookingStatus.checkedIn,
                              );
                            } catch (_) {
                              try {
                                _booking = roomState.allBookings.firstWhere((b) => b.roomId == r.id);
                              } catch (_) {
                                _booking = null;
                              }
                            }

                            return DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                'Room ${r.roomNumber} - ${_booking?.guestName ?? 'Unknown'}',
                              ),
                            );
                          } catch (e, st) {
                            debugPrint('PaymentDialog item build error for room ${r.id}: $e\n$st');
                            return DropdownMenuItem(
                              value: r.id,
                              child: Text('Room ${r.roomNumber} - Unknown'),
                            );
                          }
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            Booking? booking;
                            try {
                              booking = roomState.allBookings.firstWhere(
                                (b) => b.roomId == val && b.status == BookingStatus.checkedIn,
                              );
                            } catch (_) {
                              try {
                                booking = roomState.allBookings.firstWhere((b) => b.roomId == val);
                              } catch (_) {
                                booking = null;
                              }
                            }

                            setState(() {
                              _selectedRoomId = val;
                              _selectedBookingId = booking?.id;
                            });
                          }
                        },
                      );
                    }
                    return const CircularProgressIndicator();
                  } catch (e, st) {
                    // Log and show a friendly error instead of red crash screen
                    debugPrint('PaymentDialog room builder error: $e\n$st');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Error loading rooms: $e',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }
                },

              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppDesign.neutral500)),
        ),
        ElevatedButton(
          onPressed: () async {
            final amount = double.tryParse(_amountController.text) ?? 0;
            if (amount <= 0) {
              CustomSnackbar.showError(context, 'Please enter a valid amount');
              return;
            }

            if (_selectedMethod == PaymentMethod.bill_to_room &&
                (_selectedRoomId == null || _selectedBookingId == null)) {
              CustomSnackbar.showError(
                context,
                'Please select a guest room for billing',
              );
              return;
            }

            try {
              await context.read<BillingCubit>().addPayment(
                billId: widget.bill.id,
                amount: amount,
                method: _selectedMethod,
                reference: _refController.text,
                roomId: _selectedRoomId,
                bookingId: _selectedBookingId,
              );

              if (context.mounted) {
                Navigator.pop(context);
                CustomSnackbar.showSuccess(
                  context,
                  'Payment of ₹$amount recorded!',
                );
              }
            } catch (e) {
              if (context.mounted) {
                CustomSnackbar.showError(
                  context,
                  'Error recording payment: $e',
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDesign.primaryStart,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Confirm Payment'),
        ),
      ],
    );
  }
}
