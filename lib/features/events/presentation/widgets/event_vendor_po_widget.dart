import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_phone_field.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Card widget to display and create vendor purchase orders for a private event
class EventVendorPOWidget extends StatelessWidget {
  final PrivateEvent event;

  const EventVendorPOWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final pos = state.eventPOs;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vendor POs',
                    style: AppDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showAddPODialog(context, event),
                  ),
                ],
              ),
              const Divider(),
              if (pos.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No POs created for this event.'),
                  ),
                )
              else
                ...pos.map((po) {
                  final vendor = state.vendors.firstWhere(
                    (v) => v.id == po.vendorId,
                    orElse: () => Vendor(
                      id: 'unknown',
                      hotelId: context.hotelId,
                      name: 'Unknown Vendor',
                      category: VendorCategory.other,
                      contactPerson: '',
                      phoneNumber: '',
                      createdOn: DateTime.now(),
                    ),
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(po.description),
                    subtitle: Text('Vendor: ${vendor.name}'),
                    trailing: Text(
                      '₹${po.cost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAddPODialog(BuildContext context, PrivateEvent event) {
    final descController = TextEditingController();
    final costController = TextEditingController();
    String? selectedVendorId;
    bool isPassedToCustomer = false;

    // Controllers for new vendor
    final newVendorNameController = TextEditingController();
    final newVendorPhoneController = TextEditingController();
    bool isAddingNewVendor = false;

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EventCubit, EventState>(
        builder: (context, state) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('New Vendor PO'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: descController,
                    label: 'Description',
                    hint: 'e.g., DJ Services',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: costController,
                    label: 'Cost',
                    hint: '0.0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (!isAddingNewVendor) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedVendorId,
                      decoration: const InputDecoration(
                        labelText: 'Select Vendor',
                      ),
                      items: [
                        ...state.vendors.map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(v.name),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => selectedVendorId = val),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => isAddingNewVendor = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Vendor Instead'),
                    ),
                  ] else ...[
                    const Divider(),
                    const Text(
                      'New Vendor Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: newVendorNameController,
                      label: 'Vendor Name',
                    ),
                    const SizedBox(height: 8),
                    AppPhoneField(
                      controller: newVendorPhoneController,
                      label: 'Phone Number',
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => isAddingNewVendor = false),
                      child: const Text('Select Existing Vendor'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Pass cost to customer?'),
                    subtitle: const Text('Include in final event bill'),
                    value: isPassedToCustomer,
                    onChanged: (val) =>
                        setState(() => isPassedToCustomer = val ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (descController.text.isEmpty ||
                      costController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  String finalVendorId = selectedVendorId ?? '';

                  if (isAddingNewVendor) {
                    if (newVendorNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter vendor name'),
                        ),
                      );
                      return;
                    }
                    final newVendor = Vendor(
                      id: context.read<EventCubit>().repository.nextId(
                        'vendors',
                        hotelId: context.hotelId,
                      ),
                      hotelId: context.hotelId,
                      name: newVendorNameController.text,
                      category: VendorCategory.other,
                      contactPerson: 'Event Admin',
                      phoneNumber: newVendorPhoneController.text,
                      createdOn: DateTime.now(),
                    );
                    if (!context.mounted) return;
                    await context.read<EventCubit>().saveVendor(newVendor);
                    finalVendorId = newVendor.id;
                  }

                  if (finalVendorId.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select or add a vendor'),
                      ),
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  context.read<EventCubit>().saveEventPO(
                    EventPO(
                      id: context.read<EventCubit>().repository.nextId(
                        'event_pos',
                        hotelId: context.hotelId,
                      ),
                      hotelId: context.hotelId,
                      eventId: event.id,
                      vendorId: finalVendorId,
                      description: descController.text,
                      cost: double.tryParse(costController.text) ?? 0.0,
                      isPassedToCustomer: isPassedToCustomer,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
