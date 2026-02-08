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
  final ValueChanged<InventoryItem?> onItemChanged;
  final ValueChanged<bool> onQualityChanged;

  const ManualItemCardWidget({
    required this.index,
    required this.input,
    required this.onRemove,
    required this.onItemChanged,
    required this.onQualityChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is! InventoryLoaded) {
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDesign.space3),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<InventoryItem>(
                        value: input.selectedItem,
                        decoration: AppDesign.inputDecoration(
                          label: 'Select Item *',
                          hint: 'Choose inventory item',
                        ),
                        items: (state).items.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.name, style: AppDesign.bodyMedium),
                          );
                        }).toList(),
                        onChanged: onItemChanged,
                        validator: (value) =>
                            value == null ? 'Please select an item' : null,
                      ),
                    ),
                    const SizedBox(width: AppDesign.space2),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppDesign.error),
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
                            RegExp(r'^\d*\.?\d{0,2}'),
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
                            RegExp(r'^\d*\.?\d{0,2}'),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: input.notesController,
                        labelText: 'Notes (optional)',
                        hintText: 'Add notes...',
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AppDesign.space3),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text(
                          'Quality OK',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: input.qualityCheckPassed,
                        onChanged: (value) => onQualityChanged(value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
