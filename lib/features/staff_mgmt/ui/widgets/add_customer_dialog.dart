import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';

import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCustomerDialog extends StatefulWidget {
  final String? initialPhone;
  final String? initialName;

  const AddCustomerDialog({super.key, this.initialPhone, this.initialName});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Customer',
                  style: AppDesign.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    if (widget.initialPhone != null)
                      'phone': widget.initialPhone,
                    if (widget.initialName != null) 'name': widget.initialName,
                  },
                  child: Column(
                    children: [
                      AppTextField(
                        name: 'name',
                        label: 'Full Name',
                        hint: 'John Doe',
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        name: 'phone',
                        label: 'Phone Number',
                        hint: '+91 9876543210',
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        name: 'email',
                        label: 'Email (Optional)',
                        hint: 'john@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.email(),
                      ),
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        name: 'idProofType',
                        label: 'ID Proof Type (Optional)',
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        name: 'idProofNumber',
                        label: 'ID Proof Number (Optional)',
                        hint: '1234 5678 9012',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                PremiumButton.primary(
                  label: _isLoading ? 'Saving...' : 'Add Customer',
                  onPressed: _isLoading ? null : _saveCustomer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final data = _formKey.currentState!.value;

      final newCustomer = Customer(
        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: data['name'],
        phone: data['phone'],
        email: data['email'],
        idProofType: data['idProofType'],
        idProofNumber: data['idProofNumber'],
        createdAt: DateTime.now(),
      );

      try {
        await context.read<CustomerCubit>().saveCustomer(newCustomer);
        if (mounted) {
          Navigator.pop(context, newCustomer);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving customer: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
