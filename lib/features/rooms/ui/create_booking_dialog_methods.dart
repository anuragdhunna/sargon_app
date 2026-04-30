// ignore_for_file: invalid_use_of_protected_member

part of 'create_booking_dialog.dart';

extension _CreateBookingDialogMethods on _CreateBookingDialogState {
  void _confirmBooking() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      final authState = context.read<AuthCubit>().state;

      if (authState is! AuthVerified) return;

      final paidAmount =
          double.tryParse(data['paidAmount']?.toString() ?? '0') ?? 0.0;

      String? finalCustomerId = _selectedCustomer?.id;
      if (finalCustomerId == null) {
        final newCustomerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
        final newCustomer = Customer(
          hotelId: widget.room.hotelId,
          id: newCustomerId,
          name: data['guestName'],
          phone: data['guestPhone'],
          email: data['guestEmail'],
          idProofType: data['idProofType'],
          idProofNumber: data['idProofNumber'],
        );
        await context.read<CustomerCubit>().saveCustomer(newCustomer);
        finalCustomerId = newCustomerId;
      }

      await context.read<RoomCubit>().createBooking(
        hotelId: widget.room.hotelId,
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
        customerId: finalCustomerId,
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

  void _addPersonDialog() {
    showDialog(
      context: context,
      builder: (context) => AccompanyingGuestDialog(
        existingPersons: _accompanyingPersons,
        onAdd: (person) {
          setState(() {
            _accompanyingPersons.add(person);
          });
        },
      ),
    );
  }

  void _onCustomerSelected(Customer? customer) {
    if (customer == null) return;

    setState(() {
      _selectedCustomer = customer;
      _formKey.currentState?.fields['guestName']?.didChange(customer.name);
      _formKey.currentState?.fields['guestPhone']?.didChange(customer.phone);
      _formKey.currentState?.fields['guestEmail']?.didChange(customer.email);
      _formKey.currentState?.fields['idProofType']?.didChange(
        customer.idProofType,
      );
      _formKey.currentState?.fields['idProofNumber']?.didChange(
        customer.idProofNumber,
      );
    });
  }

  void _showAddCustomerDialog(BuildContext context) async {
    final newCustomer = await showDialog<Customer>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: const AddCustomerDialog(),
      ),
    );

    if (newCustomer != null && mounted) {
      _onCustomerSelected(newCustomer);
    }
  }
}
