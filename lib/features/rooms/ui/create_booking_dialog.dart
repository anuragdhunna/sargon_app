import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:intl/intl.dart';

/// Enhanced booking dialog with ID proofs and guest management
class CreateBookingDialog extends StatefulWidget {
  final Room room;

  const CreateBookingDialog({super.key, required this.room});

  @override
  State<CreateBookingDialog> createState() => _CreateBookingDialogState();
}

class _CreateBookingDialogState extends State<CreateBookingDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final List<Map<String, String>> _accompanyingPersons = [];
  Customer? _selectedCustomer;
  String? _idProofImageUrl;

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.book_online,
                  size: 32,
                  color: AppDesign.primaryStart,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Booking',
                        style: AppDesign.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Room ${widget.room.roomNumber} - ${widget.room.type.displayName}',
                        style: AppDesign.bodyMedium.copyWith(
                          color: AppDesign.neutral500,
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

            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'checkIn': _checkInDate,
                    'checkOut': _checkOutDate,
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guest Information Section
                      Text(
                        'Guest Information',
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Existing Customer Selection
                      BlocBuilder<CustomerCubit, CustomerState>(
                        builder: (context, state) {
                          if (state is CustomerLoaded &&
                              state.customers.isNotEmpty) {
                            return Column(
                              children: [
                                AppDropdown<Customer>(
                                  name: 'customer_select',
                                  label: 'Select Existing Customer (Optional)',
                                  items: state.customers.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text('${c.name} (${c.phone})'),
                                    );
                                  }).toList(),
                                  onChanged: (customer) {
                                    if (customer != null) {
                                      setState(() {
                                        _selectedCustomer = customer;
                                        _formKey
                                            .currentState
                                            ?.fields['guestName']
                                            ?.didChange(customer.name);
                                        _formKey
                                            .currentState
                                            ?.fields['guestPhone']
                                            ?.didChange(customer.phone);
                                        _formKey
                                            .currentState
                                            ?.fields['guestEmail']
                                            ?.didChange(customer.email);
                                        _formKey
                                            .currentState
                                            ?.fields['idProofType']
                                            ?.didChange(customer.idProofType);
                                        _formKey
                                            .currentState
                                            ?.fields['idProofNumber']
                                            ?.didChange(customer.idProofNumber);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      AppTextField(
                        name: 'guestName',
                        label: 'Primary Guest Name',
                        hint: 'John Doe',
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              name: 'guestPhone',
                              label: 'Phone Number',
                              hint: '+91 9876543210',
                              keyboardType: TextInputType.phone,
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              name: 'guestEmail',
                              label: 'Email (Optional)',
                              hint: 'john@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: FormBuilderValidators.email(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ID Proof Section
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<String>(
                              name: 'idProofType',
                              label: 'ID Proof Type',
                              items: const [
                                DropdownMenuItem(
                                  value: 'aadhar',
                                  child: Text('Aadhar Card'),
                                ),
                                DropdownMenuItem(
                                  value: 'passport',
                                  child: Text('Passport'),
                                ),
                                DropdownMenuItem(
                                  value: 'driving_license',
                                  child: Text('Driving License'),
                                ),
                                DropdownMenuItem(
                                  value: 'voter_id',
                                  child: Text('Voter ID'),
                                ),
                                DropdownMenuItem(
                                  value: 'pan_card',
                                  child: Text('PAN Card'),
                                ),
                              ],
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              name: 'idProofNumber',
                              label: 'ID Proof Number',
                              hint: '1234 5678 9012',
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Number of Guests
                      AppTextField(
                        name: 'numberOfGuests',
                        label: 'Number of Guests',
                        hint: '1',
                        prefixIcon: Icons.people,
                        keyboardType: TextInputType.number,
                        initialValue: '1',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.min(1),
                          FormBuilderValidators.max(widget.room.capacity),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // Booking Dates Section
                      Text(
                        'Booking Period',
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            initialDateRange: DateTimeRange(
                              start: _checkInDate ?? DateTime.now(),
                              end:
                                  _checkOutDate ??
                                  DateTime.now().add(const Duration(days: 1)),
                            ),
                          );
                          if (range != null) {
                            setState(() {
                              _checkInDate = range.start;
                              _checkOutDate = range.end;
                              _formKey.currentState?.fields['checkIn']
                                  ?.didChange(range.start);
                              _formKey.currentState?.fields['checkOut']
                                  ?.didChange(range.end);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppDesign.neutral300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppDesign.primaryStart,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _checkInDate != null && _checkOutDate != null
                                      ? '${DateFormat('MMM dd').format(_checkInDate!)} - ${DateFormat('MMM dd, yyyy').format(_checkOutDate!)}'
                                      : 'Select Dates',
                                  style: AppDesign.bodyMedium,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Advance Payment Section
                      Text(
                        'Payment Details',
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppDesign.primaryStart.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppDesign.primaryStart.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Nights'),
                                Text(
                                  '${_getNights()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Booking Total'),
                                Text(
                                  '₹${_calculateTotal()}',
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
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              name: 'paidAmount',
                              label: 'Advance Paid',
                              hint: '0.00',
                              prefixIcon: Icons.currency_rupee,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppDropdown<PaymentMethod>(
                              name: 'paymentMethod',
                              label: 'Method',
                              items: PaymentMethod.values.map((method) {
                                return DropdownMenuItem(
                                  value: method,
                                  child: Text(method.displayName),
                                );
                              }).toList(),
                              initialValue: PaymentMethod.cash,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        name: 'paymentReference',
                        label: 'Reference (Optional)',
                        hint: 'UPI ID, Card Transaction, etc.',
                      ),
                      const SizedBox(height: 8),

                      // Hidden redundant fields for validation
                      const SizedBox.shrink(),
                      FormBuilderField<DateTime>(
                        name: 'checkIn',
                        validator: FormBuilderValidators.required(),
                        builder: (field) => const SizedBox.shrink(),
                      ),
                      FormBuilderField<DateTime>(
                        name: 'checkOut',
                        validator: FormBuilderValidators.required(),
                        builder: (field) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppDesign.neutral500),
                  ),
                ),
                const SizedBox(width: 16),
                PremiumButton.primary(
                  label: 'Confirm Booking',
                  onPressed: _confirmBooking,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      final authState = context.read<AuthCubit>().state;

      if (authState is! AuthVerified) return;

      final paidAmount =
          double.tryParse(data['paidAmount']?.toString() ?? '0') ?? 0.0;

      await context.read<RoomCubit>().createBooking(
        roomId: widget.room.id,
        guestName: data['guestName'],
        guestPhone: data['guestPhone'],
        guestEmail: data['guestEmail'],
        checkIn: data['checkIn'],
        checkOut: data['checkOut'],
        totalAmount: _calculateTotal(),
        bookedByUserId: authState.userId,
        bookedByUserName: authState.userName,
        bookedByUserRole: authState.role.name,
        idProofType: data['idProofType'],
        idProofNumber: data['idProofNumber'],
        numberOfGuests:
            int.tryParse(data['numberOfGuests']?.toString() ?? '1') ?? 1,
        accompanyingPersons: _accompanyingPersons,
        customerId: _selectedCustomer?.id,
        idProofImageUrl: _idProofImageUrl,
        paidAmount: paidAmount,
        paymentMethod: data['paymentMethod'],
        paymentReference: data['paymentReference'],
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  int _getNights() {
    if (_checkInDate == null || _checkOutDate == null) return 1;
    final diff = _checkOutDate!.difference(_checkInDate!).inDays;
    return diff > 0 ? diff : 1;
  }

  double _calculateTotal() {
    return widget.room.pricePerNight * _getNights();
  }
}
