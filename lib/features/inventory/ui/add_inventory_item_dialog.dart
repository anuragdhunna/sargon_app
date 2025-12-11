import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../inventory_index.dart';

class AddInventoryItemDialog extends StatelessWidget {
  const AddInventoryItemDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

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
              Text(
                'Add New Item',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    AppTextField(
                      name: 'name',
                      label: 'Item Name',
                      hint: 'e.g., Basmati Rice',
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<ItemCategory>(
                            name: 'category',
                            initialValue: ItemCategory.food,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: ItemCategory.values
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormBuilderDropdown<UnitType>(
                            name: 'unit',
                            initialValue: UnitType.kg,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: UnitType.values
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            name: 'quantity',
                            label: 'Current Stock',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            name: 'minQuantity',
                            label: 'Min Level (Par)',
                            hint: '10',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      name: 'price',
                      label: 'Price Per Unit (₹)',
                      hint: '50.0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        (val) {
                          if (val != null &&
                              double.tryParse(val) != null &&
                              double.parse(val) <= 0) {
                            return 'Price must be greater than 0';
                          }
                          return null;
                        },
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PremiumButton.secondary(
                    label: 'Cancel',
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 16),
                  PremiumButton.primary(
                    label: 'Add Item',
                    icon: Icons.add,
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        final data = formKey.currentState!.value;
                        try {
                          final item = InventoryItem(
                            id: const Uuid().v4(),
                            name: data['name'],
                            category: data['category'],
                            quantity: double.parse(data['quantity'] ?? '0'),
                            minQuantity: double.parse(
                              data['minQuantity'] ?? '0',
                            ),
                            unit: data['unit'],
                            pricePerUnit: double.parse(data['price'] ?? '0'),
                          );

                          final authState = context.read<AuthCubit>().state;
                          if (authState is AuthVerified) {
                            context.read<InventoryCubit>().addItem(
                              item,
                              userId: authState.userId,
                              userName: authState.userName,
                              userRole: authState.role.name,
                            );
                            context.pop();
                            CustomSnackbar.showSuccess(
                              context,
                              'Item added successfully!',
                            );
                          }
                        } catch (e) {
                          CustomSnackbar.showError(
                            context,
                            'Invalid input. Please check all fields.',
                          );
                        }
                      } else {
                        CustomSnackbar.showError(
                          context,
                          'Please fix the errors in the form',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
