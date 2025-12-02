import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/component/inputs/custom_text_field.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/data/room_model.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';

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
  final TextEditingController _personNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),
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
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Booking',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Room ${widget.room.roomNumber} - ${widget.room.type.displayName}',
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

            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guest Information Section
                      Text(
                        'Guest Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        name: 'guestName',
                        label: 'Primary Guest Name',
                        hint: 'John Doe',
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              name: 'guestPhone',
                              label: 'Phone Number',
                              hint: '+91 9876543210',
                              keyboardType: TextInputType.phone,
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              name: 'guestEmail',
                              label: 'Email (Optional)',
                              hint: 'john@example.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ID Proof Section
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderDropdown<String>(
                              name: 'idProofType',
                              decoration: const InputDecoration(
                                labelText: 'ID Proof Type',
                                border: OutlineInputBorder(),
                              ),
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
                            child: CustomTextField(
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
                      FormBuilderTextField(
                        name: 'numberOfGuests',
                        decoration: const InputDecoration(
                          labelText: 'Number of Guests',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
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

                      // Accompanying Persons Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Accompanying Persons',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddPersonDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Person'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_accompanyingPersons.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'No accompanying persons added',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...List.generate(_accompanyingPersons.length, (index) {
                          final person = _accompanyingPersons[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(person['name'] ?? ''),
                              subtitle: Text(
                                '${person['idType']} - ${person['idNumber']}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => setState(
                                  () => _accompanyingPersons.removeAt(index),
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 24),

                      // Booking Dates Section
                      Text(
                        'Booking Period',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderDateTimePicker(
                              name: 'checkIn',
                              decoration: const InputDecoration(
                                labelText: 'Check-In Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              inputType: InputType.date,
                              initialValue: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              onChanged: (date) =>
                                  setState(() => _checkInDate = date),
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderDateTimePicker(
                              name: 'checkOut',
                              decoration: const InputDecoration(
                                labelText: 'Check-Out Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              inputType: InputType.date,
                              initialValue: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              firstDate: _checkInDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              onChanged: (date) =>
                                  setState(() => _checkOutDate = date),
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Price per night'),
                                Text(
                                  '₹${widget.room.pricePerNight}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_checkInDate != null &&
                                _checkOutDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Nights: ${_getNights()}'),
                                  Text(
                                    'Total: ₹${_calculateTotal()}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: PrimaryButton(
                    label: 'Confirm Booking',
                    onPressed: _confirmBooking,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final idNumberController = TextEditingController();
    String? selectedIdType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Accompanying Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'ID Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Aadhar', child: Text('Aadhar Card')),
                DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                DropdownMenuItem(value: 'DL', child: Text('Driving License')),
              ],
              onChanged: (value) => selectedIdType = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  selectedIdType != null &&
                  idNumberController.text.isNotEmpty) {
                setState(() {
                  _accompanyingPersons.add({
                    'name': nameController.text,
                    'idType': selectedIdType!,
                    'idNumber': idNumberController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      final authState = context.read<AuthCubit>().state;

      if (authState is! AuthVerified) return;

      // Create booking with full metadata
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
        metadata: {
          'idProofType': data['idProofType'],
          'idProofNumber': data['idProofNumber'],
          'numberOfGuests': data['numberOfGuests'],
          'accompanyingPersons': _accompanyingPersons,
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking confirmed for ${data['guestName']} in Room ${widget.room.roomNumber}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  int _getNights() {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double _calculateTotal() {
    return widget.room.pricePerNight * _getNights();
  }
}
