import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Login Screen using Firebase Email/Password Authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo/Title
                          Icon(
                            Icons.hotel_rounded,
                            size: 64,
                            color: AppDesign.primaryStart,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sargon Hotel',
                            textAlign: TextAlign.center,
                            style: AppDesign.headlineLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppDesign.neutral900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to manage your hotel',
                            textAlign: TextAlign.center,
                            style: AppDesign.bodyMedium.copyWith(
                              color: AppDesign.neutral600,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Login Form
                          FormBuilder(
                            key: _formKey,
                            child: Column(
                              children: [
                                AppTextField(
                                  name: 'email',
                                  label: 'Email',
                                  hint: 'your.email@hotel.com',
                                  initialValue: 'owner@sargon.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.email(),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  name: 'password',
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  initialValue: '111111',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppDesign.neutral500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(6),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          BlocConsumer<AuthCubit, AuthState>(
                            listener: (context, state) {
                              if (state is AuthError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: AppDesign.error,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return PremiumButton.primary(
                                label: isLoading ? 'Signing in...' : 'Sign In',
                                isFullWidth: true,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState
                                                ?.saveAndValidate() ??
                                            false) {
                                          final values =
                                              _formKey.currentState!.value;
                                          context
                                              .read<AuthCubit>()
                                              .signInWithEmailPassword(
                                                email:
                                                    values['email'] as String,
                                                password:
                                                    values['password']
                                                        as String,
                                              );
                                        }
                                      },
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Quick Login Section (Development)
                          Text(
                            'Quick Login (Dev Mode)',
                            textAlign: TextAlign.center,
                            style: AppDesign.labelLarge.copyWith(
                              color: AppDesign.neutral500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Password: 111111',
                            textAlign: TextAlign.center,
                            style: AppDesign.bodySmall.copyWith(
                              color: AppDesign.neutral400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _QuickLoginChip(
                                role: UserRole.owner,
                                color: Colors.red,
                              ),
                              _QuickLoginChip(
                                role: UserRole.manager,
                                color: Colors.deepPurple,
                              ),
                              _QuickLoginChip(
                                role: UserRole.frontDesk,
                                color: Colors.blue,
                              ),
                              _QuickLoginChip(
                                role: UserRole.chef,
                                color: Colors.orange,
                              ),
                              _QuickLoginChip(
                                role: UserRole.waiter,
                                color: Colors.green,
                              ),
                              _QuickLoginChip(
                                role: UserRole.housekeeping,
                                color: Colors.teal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Establishing Session...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Quick login chip for development mode
class _QuickLoginChip extends StatelessWidget {
  final UserRole role;
  final Color color;

  const _QuickLoginChip({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: color.withAlpha(50),
        radius: 12,
        child: Icon(Icons.person, size: 14, color: color),
      ),
      label: Text(
        role.name.toUpperCase(),
        style: AppDesign.bodySmall.copyWith(fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withAlpha(25),
      side: BorderSide(color: color.withAlpha(75)),
      onPressed: () {
        context.read<AuthCubit>().loginAsPersona(role);
      },
    );
  }
}
