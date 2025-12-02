import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/component/inputs/custom_text_field.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your phone number to sign in to your dashboard.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      name: 'phone',
                      label: 'Phone Number',
                      hint: '9876543210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone,
                      maxLength: 10,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.minLength(10),
                        FormBuilderValidators.maxLength(10),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthCodeSent) {
                    context.push('/otp');
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return PrimaryButton(
                    label: state is AuthLoading ? 'Sending...' : 'Send OTP',
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (formKey.currentState?.saveAndValidate() ??
                                false) {
                              final phone =
                                  formKey.currentState!.value['phone']
                                      as String;
                              context.read<AuthCubit>().sendOtp(phone);
                            }
                          },
                  );
                },
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Quick Login (Dev)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PersonaButton(
                    role: UserRole.owner,
                    label: 'Owner (Admin)',
                    phone: '9876543210',
                    color: Colors.red,
                  ),
                  _PersonaButton(
                    role: UserRole.manager,
                    label: 'Manager',
                    phone: '9876543215',
                    color: Colors.deepPurple,
                  ),
                  _PersonaButton(
                    role: UserRole.frontDesk,
                    label: 'Front Desk',
                    phone: '9876543211',
                    color: Colors.blue,
                  ),
                  _PersonaButton(
                    role: UserRole.housekeeping,
                    label: 'Housekeeping',
                    phone: '9876543212',
                    color: Colors.green,
                  ),
                  _PersonaButton(
                    role: UserRole.waiter,
                    label: 'Waiter',
                    phone: '9876543213',
                    color: Colors.orange,
                  ),
                  _PersonaButton(
                    role: UserRole.chef,
                    label: 'Chef',
                    phone: '9876543214',
                    color: Colors.purple,
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaButton extends StatelessWidget {
  final UserRole role;
  final String label;
  final String phone;
  final Color color;

  const _PersonaButton({
    required this.role,
    required this.label,
    required this.phone,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(Icons.person, size: 14, color: color),
      ),
      label: Text('$label ($phone)'),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: phone));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Copied $phone to clipboard')));
        }
      },
    );
  }
}
