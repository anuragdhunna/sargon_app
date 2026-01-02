import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dialog for adding new staff members
///
/// Creates a Firebase Auth account with default password '111111'
/// and stores the user profile in the Realtime Database.
/// Only accessible to admin (owner) and manager roles.
class AddUserDialog extends StatefulWidget {
  final User? user; // Pass user for edit mode

  const AddUserDialog({super.key, this.user});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditMode => widget.user != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.person_add,
                    color: AppDesign.primaryStart,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Staff Member' : 'Add New Staff Member',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              if (!isEditMode) ...[
                const SizedBox(height: 8),
                Text(
                  'Default password: 111111',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral500,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppDesign.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppDesign.error.withAlpha(75)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppDesign.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form
              FormBuilder(
                key: _formKey,
                initialValue: isEditMode
                    ? {
                        'name': widget.user!.name,
                        'email': widget.user!.email,
                        'phone': widget.user!.phoneNumber,
                        'role': widget.user!.role,
                        'salary':
                            widget.user!.paymentType ==
                                PaymentType.monthlySalary
                            ? widget.user!.monthlySalary?.toString()
                            : widget.user!.dailyWage?.toString(),
                        'paymentType': widget.user!.paymentType,
                      }
                    : {
                        'role': UserRole.waiter,
                        'paymentType': PaymentType.monthlySalary,
                      },
                child: Column(
                  children: [
                    AppTextField(
                      name: 'name',
                      label: 'Full Name',
                      hint: 'John Doe',
                      prefixIcon: Icons.person_outline,
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      name: 'email',
                      label: 'Email',
                      hint: 'john@sargon.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isEditMode, // Email cannot be changed
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      name: 'phone',
                      label: 'Phone Number',
                      hint: '+91 98765 43210',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(10),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Role',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderDropdown<UserRole>(
                      name: 'role',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.work_outline),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: UserRole.values
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(_getRoleDisplayName(role)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<PaymentType>(
                            name: 'paymentType',
                            decoration: const InputDecoration(
                              labelText: 'Payment Type',
                              border: OutlineInputBorder(),
                            ),
                            items: PaymentType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type == PaymentType.monthlySalary
                                          ? 'Monthly Salary'
                                          : 'Daily Wage',
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            name: 'salary',
                            label: 'Amount (INR)',
                            hint: '15000',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.numeric(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  PremiumButton.primary(
                    label: _isLoading
                        ? (isEditMode ? 'Saving...' : 'Creating...')
                        : (isEditMode ? 'Save Changes' : 'Create Account'),
                    onPressed: _isLoading ? null : _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final values = _formKey.currentState!.value;
    final salary = double.tryParse(values['salary']?.toString() ?? '0') ?? 0;
    final paymentType = values['paymentType'] as PaymentType;

    if (isEditMode) {
      final updatedUser = widget.user!.copyWith(
        name: values['name'] as String,
        phoneNumber: values['phone'] as String,
        role: values['role'] as UserRole,
        paymentType: paymentType,
        dailyWage: paymentType == PaymentType.dailyWage ? salary : 0,
        monthlySalary: paymentType == PaymentType.monthlySalary ? salary : 0,
        updatedAt: DateTime.now(),
      );

      await context.read<UserCubit>().addUser(updatedUser);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppDesign.success,
          ),
        );
      }
    } else {
      final authService = context.read<AuthService>();
      final result = await authService.createStaffAccount(
        email: values['email'] as String,
        name: values['name'] as String,
        phoneNumber: values['phone'] as String,
        role: values['role'] as UserRole,
        password: '111111',
      );

      if (result.success && result.user != null) {
        // Update user with salary details since createStaffAccount only sets basic info
        final userWithSalary = result.user!.copyWith(
          paymentType: paymentType,
          dailyWage: paymentType == PaymentType.dailyWage ? salary : 0,
          monthlySalary: paymentType == PaymentType.monthlySalary ? salary : 0,
        );
        await context.read<UserCubit>().addUser(userWithSalary);

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: AppDesign.success,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.errorMessage;
        });
      }
    }
  }

  String _getRoleDisplayName(UserRole role) {
    return role.displayName;
  }
}
