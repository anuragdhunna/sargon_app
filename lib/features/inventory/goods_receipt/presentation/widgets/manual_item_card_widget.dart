import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_inputs.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart'
    show InventoryCubit;
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
import 'package:hotel_manager/theme/app_design.dart';

class ManualItemCardWidget extends StatelessWidget {
  final int index;
  final ManualItemInput input;
  final VoidCallback onRemove;
  const ManualItemCardWidget({
    required this.index,
    required this.input,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is! InventoryLoaded) {
          return const SizedBox();
        }
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<InventoryItem>(
                      initialValue: input.selectedItem,
                      decoration: InputDecoration(
                        labelText: 'Select Item *',
                        labelStyle: AppDesign.labelLarge,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesign.radiusMd,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesign.radiusMd,
                          ),
                          borderSide: BorderSide(color: AppDesign.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesign.radiusMd,
                          ),
                          borderSide: BorderSide(
                            color: AppDesign.primaryStart,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppDesign.neutral50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.space3,
                          vertical: AppDesign.space2,
                        ),
                      ),
                      items: (state).items.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.name, style: AppDesign.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // parent should handle state update via a callback
                      },
                      validator: (value) =>
                          value == null ? 'Please select an item' : null,
                    ),
                  ),
                  const SizedBox(width: AppDesign.space2),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppDesign.error),
                    onPressed: onRemove,
                    tooltip: 'Remove item',
                  ),
                ],
              ),
              const SizedBox(height: AppDesign.space3),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: input.quantityController,
                      labelText: 'Quantity *',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\\d+\\.?\\d{0,2}'),
                        ),
                      ],
                      suffixIcon: input.selectedItem != null
                          ? Padding(
                              padding: const EdgeInsets.all(AppDesign.space3),
                              child: Text(
                                input.selectedItem!.unit.name,
                                style: AppDesign.bodySmall.copyWith(
                                  color: AppDesign.neutral600,
                                ),
                              ),
                            )
                          : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final qty = double.tryParse(value);
                        if (qty == null || qty <= 0) {
                          return 'Invalid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppDesign.space3),
                  Expanded(
                    child: AppTextField(
                      controller: input.priceController,
                      labelText: 'Price *',
                      hintText: '0.00',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\\d+\\.?\\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesign.space3),
              AppTextField(
                controller: input.notesController,
                labelText: 'Notes (optional)',
                hintText: 'Add any notes about this item',
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
