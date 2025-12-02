import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_inputs.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart'
    show InventoryCubit;
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
// adjust path if needed

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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<InventoryItem>(
                        initialValue: input.selectedItem,
                        decoration: const InputDecoration(
                          labelText: 'Select Item *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: (state).items.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // parent should handle state update via a callback; omitted here for brevity
                        },
                        validator: (value) =>
                            value == null ? 'Please select an item' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: input.quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity *',
                          border: const OutlineInputBorder(),
                          suffix: Text(input.selectedItem?.unit.name ?? ''),
                        ),
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
                          final qty = double.tryParse(value);
                          if (qty == null || qty <= 0) {
                            return 'Invalid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: input.priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          border: OutlineInputBorder(),
                        ),
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
                const SizedBox(height: 8),
                TextFormField(
                  controller: input.notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
