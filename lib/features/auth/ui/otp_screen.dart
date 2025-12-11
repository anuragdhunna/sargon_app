import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/component/buttons/secondary_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/auth/role_guard.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We have sent a 6-digit code to your phone number.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              FormBuilder(
                key: formKey,
                child: AppTextField(
                  name: 'otp',
                  label: 'Enter OTP',
                  hint: '123456',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline,
                  maxLength: 6,
                  initialValue: '111111',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.minLength(6),
                    FormBuilderValidators.maxLength(6),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthVerified) {
                    // Navigate to the default route for this role
                    final defaultRoute = RoleGuard.getDefaultRoute(state.role);
                    context.go(defaultRoute);
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return PrimaryButton(
                    label: state is AuthLoading
                        ? 'Verifying...'
                        : 'Verify & Login',
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (formKey.currentState?.saveAndValidate() ??
                                false) {
                              final otp =
                                  formKey.currentState!.value['otp'] as String;
                              context.read<AuthCubit>().verifyOtp(otp);
                            }
                          },
                  );
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Resend Code',
                onPressed: () {
                  // TODO: Resend logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
