import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/constants/app_features.dart';

class EditOwnerScreen extends StatefulWidget {
  static const String routeName = '/edit-owner';
  final User owner;

  const EditOwnerScreen({super.key, required this.owner});

  @override
  State<EditOwnerScreen> createState() => _EditOwnerScreenState();
}

class _EditOwnerScreenState extends State<EditOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  String? _selectedHotelId;
  List<String>? _selectedFeatures;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.owner.name);
    _phoneController = TextEditingController(text: widget.owner.phoneNumber);
    _isActive = widget.owner.status == UserStatus.active;
    if (widget.owner.hotelIds.isNotEmpty) {
      _selectedHotelId = widget.owner.hotelIds.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final databaseService = context.read<DatabaseService>();
        final authService = context.read<AuthService>();

        final updatedOwner = widget.owner.copyWith(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          status: _isActive ? UserStatus.active : UserStatus.inactive,
        );

        // Update user profile basic details
        await authService.updateUserProfile(updatedOwner);

        // Handle hotel assignment if selected (and changed)
        if (_selectedHotelId != null) {
          // Add to DB hotel assignment
          await databaseService.assignOwnerToHotel(
            hotelId: _selectedHotelId!,
            ownerId: widget.owner.id,
          );

          if (_selectedFeatures != null) {
            final hotel = await databaseService.getHotel(_selectedHotelId!);
            if (hotel != null) {
              await databaseService.saveHotel(
                hotel.copyWith(enabledFeatures: _selectedFeatures!),
              );
            }
          }

          // Update user hotelIds list
          if (!updatedOwner.hotelIds.contains(_selectedHotelId)) {
            final newHotelIds = List<String>.from(updatedOwner.hotelIds)
              ..add(_selectedHotelId!);
            await authService.updateUserProfile(
              updatedOwner.copyWith(hotelIds: newHotelIds),
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Owner updated successfully')),
          );
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Edit Owner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesign.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Details', style: AppDesign.titleLarge),
                const SizedBox(height: AppDesign.space4),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppDesign.space4),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppDesign.space4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active Account'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeThumbColor: AppDesign.primaryStart,
                ),
                const SizedBox(height: AppDesign.space6),
                Text('Assign Hotel', style: AppDesign.titleLarge),
                const SizedBox(height: AppDesign.space4),
                StreamBuilder<List<Hotel>>(
                  stream: databaseService.streamAllHotels(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Failed to load hotels',
                        style: TextStyle(color: Colors.red.shade400),
                      );
                    }
                    final hotels = snapshot.data ?? [];
                    if (hotels.isEmpty) {
                      return const Text('No hotels available to assign.');
                    }

                    // Protect against assigning a hotel ID that is no longer in the list
                    if (_selectedHotelId != null &&
                        !hotels.any((h) => h.id == _selectedHotelId)) {
                      _selectedHotelId = null;
                      _selectedFeatures = null;
                    } else if (_selectedHotelId != null &&
                        _selectedFeatures == null) {
                      try {
                        final h = hotels.firstWhere(
                          (h) => h.id == _selectedHotelId,
                        );
                        _selectedFeatures = List.from(h.enabledFeatures);
                      } catch (_) {}
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedHotelId,
                          decoration: InputDecoration(
                            labelText: 'Select Hotel',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDesign.radiusMd,
                              ),
                            ),
                            filled: true,
                            fillColor: AppDesign.neutral50,
                          ),
                          items: hotels.map((h) {
                            return DropdownMenuItem(
                              value: h.id,
                              child: Text(h.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedHotelId = val;
                              if (val != null) {
                                try {
                                  final h = hotels.firstWhere(
                                    (h) => h.id == val,
                                  );
                                  _selectedFeatures = List.from(
                                    h.enabledFeatures,
                                  );
                                } catch (_) {
                                  _selectedFeatures = [];
                                }
                              } else {
                                _selectedFeatures = null;
                              }
                            });
                          },
                        ),
                        if (_selectedHotelId != null &&
                            _selectedFeatures != null) ...[
                          const SizedBox(height: AppDesign.space6),
                          Text('Hotel Features', style: AppDesign.titleLarge),
                          const SizedBox(height: AppDesign.space2),
                          ...AppFeatures.allFeatures.map((feature) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(AppFeatures.getFeatureName(feature)),
                              value: _selectedFeatures!.contains(feature),
                              activeColor: AppDesign.primaryStart,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedFeatures!.add(feature);
                                    _selectedFeatures =
                                        AppFeatures.withEnforcedDependencies(
                                          _selectedFeatures!,
                                        );
                                  } else {
                                    _selectedFeatures!.remove(feature);
                                    _selectedFeatures =
                                        AppFeatures.withEnforcedRemovals(
                                          _selectedFeatures!,
                                          feature,
                                        );
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDesign.space6),
                PremiumButton.primary(
                  onPressed: _isLoading ? null : _submit,
                  label: 'Save Changes',
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
