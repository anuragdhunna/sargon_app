import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';

class CustomerDetailsDialog extends StatefulWidget {
  final Function(Customer?) onConfirm;

  const CustomerDetailsDialog({super.key, required this.onConfirm});

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer Details (Loyalty)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter phone number to link this bill to a customer for loyalty points.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Search by phone...',
              keyboardType: TextInputType.phone,
              onChanged: (val) {
                final state = context.read<CustomerCubit>().state;
                if (state is CustomerLoaded) {
                  final customer = state.customers
                      .where((c) => c.phone == val)
                      .toList();
                  if (customer.isNotEmpty) {
                    setState(() {
                      _selectedCustomer = customer.first;
                      _nameController.text = customer.first.name;
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: 'Customer Name',
              hint: 'Enter name...',
              enabled: _selectedCustomer == null,
            ),
            if (_selectedCustomer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Points: ${_selectedCustomer!.loyaltyInfo?.availablePoints ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onConfirm(null);
            Navigator.pop(context);
          },
          child: const Text('Skip (No Loyalty)'),
        ),
        PremiumButton.primary(
          label: 'Continue',
          onPressed: () async {
            if (_selectedCustomer == null && _phoneController.text.isNotEmpty) {
              // Create new guest
              final newCustomer = Customer(
                id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'Walking Guest',
                phone: _phoneController.text,
              );
              await context.read<CustomerCubit>().saveCustomer(newCustomer);
              widget.onConfirm(newCustomer);
            } else {
              widget.onConfirm(_selectedCustomer);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
