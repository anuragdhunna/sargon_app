import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/widgets/add_customer_dialog.dart';

class CustomerDetailsDialog extends StatefulWidget {
  final Function(Customer?) onConfirm;

  const CustomerDetailsDialog({super.key, required this.onConfirm});

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer Details (Loyalty)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a customer to link this bill for loyalty points.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoaded) {
                  return Row(
                    children: [
                      Expanded(
                        child: AppDropdown<Customer?>(
                          name: 'customer',
                          label: 'Select Customer',
                          initialValue: _selectedCustomer,
                          items: state.customers.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text('${c.name} (${c.phone})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCustomer = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: IconButton.filled(
                          onPressed: () => _showAddCustomerDialog(context),
                          icon: const Icon(Icons.add),
                          tooltip: 'Add New Customer',
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            if (_selectedCustomer != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Loyalty Points: ${_selectedCustomer!.loyaltyInfo?.availablePoints ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
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
          onPressed: () {
            widget.onConfirm(_selectedCustomer);
            Navigator.pop(context);
          },
        ),
      ],
    );
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
      setState(() {
        _selectedCustomer = newCustomer;
      });
    }
  }
}
