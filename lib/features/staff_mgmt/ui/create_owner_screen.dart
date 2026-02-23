import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/owner_registration_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';

class CreateOwnerScreen extends StatefulWidget {
  const CreateOwnerScreen({super.key});

  static const String routeName = '/create-owner';

  @override
  State<CreateOwnerScreen> createState() => _CreateOwnerScreenState();
}

class _CreateOwnerScreenState extends State<CreateOwnerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _newHotelNameController = TextEditingController();
  final _newHotelAddressController = TextEditingController();

  bool _isCreatingNewHotel = true;
  String? _selectedExistingHotelId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _newHotelNameController.dispose();
    _newHotelAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isCreatingNewHotel && _selectedExistingHotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an existing hotel')),
      );
      return;
    }

    context.read<OwnerRegistrationCubit>().registerOwner(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      existingHotelId: _isCreatingNewHotel ? null : _selectedExistingHotelId,
      newHotelName: _isCreatingNewHotel
          ? _newHotelNameController.text.trim()
          : null,
      newHotelAddress: _isCreatingNewHotel
          ? _newHotelAddressController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Create Hotel Owner'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<OwnerRegistrationCubit, OwnerRegistrationState>(
        listener: (context, state) {
          if (state is OwnerRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppDesign.success,
              ),
            );
            context.pop(); // Go back to management screen
          } else if (state is OwnerRegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppDesign.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OwnerRegistrationLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesign.space4),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('Basic Details'),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hintText: 'Enter owner name',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppDesign.space3),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: AppDesign.space4),
                  _buildSectionHeader('Login Details'),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        !v!.contains('@') ? 'Invalid email' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppDesign.space3),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter a strong password',
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: AppDesign.space4),
                  _buildSectionHeader('Hotel Assignment'),
                  Container(
                    padding: const EdgeInsets.all(AppDesign.space2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radiusLg),
                      border: Border.all(color: AppDesign.neutral200),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: const Text('Create New Hotel'),
                          value: true,
                          groupValue: _isCreatingNewHotel,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _isCreatingNewHotel = v!),
                        ),
                        RadioListTile<bool>(
                          title: const Text('Assign Existing Hotel'),
                          value: false,
                          groupValue: _isCreatingNewHotel,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _isCreatingNewHotel = v!),
                        ),
                      ],
                    ),
                  ),

                  if (_isCreatingNewHotel) ...[
                    const SizedBox(height: AppDesign.space3),
                    AppTextField(
                      controller: _newHotelNameController,
                      label: 'Hotel Name',
                      hintText: 'Enter new hotel name',
                      validator: (v) =>
                          _isCreatingNewHotel && v!.isEmpty ? 'Required' : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppDesign.space3),
                    AppTextField(
                      controller: _newHotelAddressController,
                      label: 'Address',
                      hintText: 'Enter hotel location/address',
                      validator: (v) =>
                          _isCreatingNewHotel && v!.isEmpty ? 'Required' : null,
                      enabled: !isLoading,
                    ),
                  ] else ...[
                    const SizedBox(height: AppDesign.space3),
                    _buildExistingHotelDropdown(isLoading),
                  ],

                  const SizedBox(height: AppDesign.space6),
                  PremiumButton.primary(
                    onPressed: isLoading ? null : _submit,
                    label: 'Create Owner & Assign',
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.space3),
      child: Text(
        title,
        style: AppDesign.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppDesign.primaryStart,
        ),
      ),
    );
  }

  Widget _buildExistingHotelDropdown(bool isLoading) {
    return StreamBuilder<List<Hotel>>(
      stream: context.read<DatabaseService>().streamAllHotels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            'Error linking hotels: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final hotels = snapshot.data ?? [];
        if (hotels.isEmpty) {
          return const Text(
            'No existing hotels found. Please create a new one.',
          );
        }

        return DropdownButtonFormField<String>(
          value: _selectedExistingHotelId,
          decoration: InputDecoration(
            labelText: 'Select Hotel',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: hotels.map((hotel) {
            return DropdownMenuItem<String>(
              value: hotel.id,
              child: Text(hotel.name),
            );
          }).toList(),
          onChanged: isLoading
              ? null
              : (v) {
                  setState(() {
                    _selectedExistingHotelId = v;
                  });
                },
          validator: (v) =>
              !_isCreatingNewHotel && v == null ? 'Required' : null,
        );
      },
    );
  }
}
