import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/attendance/logic/attendance_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';

class AttendanceRegularizationDialog extends StatefulWidget {
  const AttendanceRegularizationDialog({super.key});

  @override
  State<AttendanceRegularizationDialog> createState() =>
      _AttendanceRegularizationDialogState();
}

class _AttendanceRegularizationDialogState
    extends State<AttendanceRegularizationDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regularize Attendance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Missed a punch? Submit a request to fix attendance record.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              BlocBuilder<UserCubit, UserState>(
                builder: (context, userState) {
                  if (userState is! UserLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final authState = context.read<AuthCubit>().state;
                  final currentUserRole = (authState is AuthVerified)
                      ? authState.role
                      : UserRole.waiter; // Default fallback

                  // Filter users based on role
                  final eligibleUsers = userState.users.where((user) {
                    if (currentUserRole == UserRole.owner) {
                      return true; // Owner sees all
                    }
                    if (currentUserRole == UserRole.manager) {
                      // Manager sees all except Owner and other Managers (and themselves)
                      return user.role != UserRole.owner &&
                          user.role != UserRole.manager;
                    }
                    return false; // Others shouldn't see this dialog
                  }).toList();

                  if (eligibleUsers.isEmpty) {
                    return const Text(
                      'No eligible employees found to regularize.',
                    );
                  }

                  return FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormBuilderDropdown<String>(
                          name: 'userId',
                          decoration: const InputDecoration(
                            labelText: 'Select Employee',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: FormBuilderValidators.required(),
                          items: eligibleUsers
                              .map(
                                (user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text(
                                    '${user.name} (${user.role.name})',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderDateTimePicker(
                          name: 'date',
                          inputType: InputType.both,
                          decoration: const InputDecoration(
                            labelText: 'Date & Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          initialValue: DateTime.now(),
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderDropdown<AttendanceType>(
                          name: 'type',
                          decoration: const InputDecoration(
                            labelText: 'Punch Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.touch_app),
                          ),
                          initialValue: AttendanceType.checkIn,
                          items: const [
                            DropdownMenuItem(
                              value: AttendanceType.checkIn,
                              child: Text('Punch In'),
                            ),
                            DropdownMenuItem(
                              value: AttendanceType.checkOut,
                              child: Text('Punch Out'),
                            ),
                          ],
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'reason',
                          decoration: const InputDecoration(
                            labelText: 'Reason',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.comment),
                            hintText: 'e.g. Forgot phone, Battery dead',
                          ),
                          maxLines: 3,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(5),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
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
                  SizedBox(
                    width: 120,
                    child: PrimaryButton(label: 'Submit', onPressed: _submit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;

      context.read<AttendanceCubit>().regularizeAttendance(
        userId: data['userId'],
        date: data['date'],
        type: data['type'],
        reason: data['reason'],
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Regularization request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
