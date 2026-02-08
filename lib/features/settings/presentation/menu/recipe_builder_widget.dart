import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/inventory_item_model.dart';
import 'package:hotel_manager/core/models/recipe_model.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/theme/app_design.dart';

class RecipeBuilderWidget extends StatefulWidget {
  final List<RecipeIngredient> initialRecipe;
  final ValueChanged<List<RecipeIngredient>> onChanged;

  const RecipeBuilderWidget({
    super.key,
    this.initialRecipe = const [],
    required this.onChanged,
  });

  @override
  State<RecipeBuilderWidget> createState() => _RecipeBuilderWidgetState();
}

class _RecipeBuilderWidgetState extends State<RecipeBuilderWidget> {
  late List<RecipeIngredient> _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = List.from(widget.initialRecipe);
    // Ensure inventory is loaded
    context.read<InventoryCubit>().loadInventory();
  }

  void _addIngredient(InventoryItem item, double quantity) {
    setState(() {
      // Check if already exists
      final existingIndex = _recipe.indexWhere(
        (i) => i.inventoryItemId == item.id,
      );
      if (existingIndex >= 0) {
        // Update quantity
        final existing = _recipe[existingIndex];
        _recipe[existingIndex] = RecipeIngredient(
          inventoryItemId: existing.inventoryItemId,
          name: existing.name,
          quantity: existing.quantity + quantity,
          unit: existing.unit,
        );
      } else {
        // Add new
        _recipe.add(
          RecipeIngredient(
            inventoryItemId: item.id,
            name: item.name,
            quantity: quantity,
            unit: item.unit,
          ),
        );
      }
      widget.onChanged(_recipe);
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _recipe.removeAt(index);
      widget.onChanged(_recipe);
    });
  }

  void _showAddIngredientSheet() {
    final cubit = context.read<InventoryCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bContext) => BlocProvider<InventoryCubit>.value(
        value: cubit,
        child: _AddIngredientSheet(onAdd: _addIngredient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recipe / Ingredients', style: AppDesign.titleMedium),
            TextButton.icon(
              key: const Key('add_ingredient_button'),
              onPressed: _showAddIngredientSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recipe.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'No ingredients added. Add ingredients to track stock automatically.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recipe.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ingredient = _recipe[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${ingredient.quantity} ${ingredient.unit.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _AddIngredientSheet extends StatefulWidget {
  final Function(InventoryItem, double) onAdd;

  const _AddIngredientSheet({required this.onAdd});

  @override
  State<_AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<_AddIngredientSheet> {
  String _searchQuery = '';
  InventoryItem? _selectedItem;
  final _qtyController = TextEditingController();
  bool _useSmallUnit = true; // Toggle for Grams/ML (Default to grams/ml)

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Ingredient', style: AppDesign.titleLarge),
          const SizedBox(height: 16),
          if (_selectedItem == null) ...[
            AppTextField(
              hint: 'Search inventory...',
              onChanged: (v) => setState(() => _searchQuery = v ?? ''),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: BlocBuilder<InventoryCubit, InventoryState>(
                builder: (context, state) {
                  if (state is! InventoryLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = state.items.where((i) {
                    // Filter: Only Food and Beverage
                    final isFoodOrBev =
                        i.category == ItemCategory.food ||
                        i.category == ItemCategory.beverage;
                    final matchesSearch = i.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                    return isFoodOrBev && matchesSearch;
                  }).toList();

                  if (items.isEmpty) {
                    return const Center(child: Text('No items found'));
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.quantity} ${item.unit.name} currently in stock',
                        ),
                        onTap: () => setState(() => _selectedItem = item),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedItem!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _qtyController,
              label: _getQuantityLabel(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            if (_canUseSmallUnit()) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text('Use ${_getSmallUnitName()}'),
                value: _useSmallUnit,
                onChanged: (v) => setState(() => _useSmallUnit = v),
              ),
            ],
            const SizedBox(height: 24),
            PremiumButton.primary(
              label: 'Add to Recipe',
              onPressed: () {
                final qty = double.tryParse(_qtyController.text);
                if (qty != null && qty > 0) {
                  // Unit Conversion Logic
                  double finalQty = qty;

                  // Convert Grams to Kg
                  if (_selectedItem!.unit == UnitType.kg && _useSmallUnit) {
                    finalQty = qty / 1000;
                  }
                  // Convert ML to Liters
                  else if (_selectedItem!.unit == UnitType.liters &&
                      _useSmallUnit) {
                    finalQty = qty / 1000;
                  }

                  widget.onAdd(_selectedItem!, finalQty);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  bool _canUseSmallUnit() {
    if (_selectedItem == null) return false;
    return _selectedItem!.unit == UnitType.kg ||
        _selectedItem!.unit == UnitType.liters;
  }

  String _getSmallUnitName() {
    if (_selectedItem?.unit == UnitType.kg) return 'Grams (g)';
    if (_selectedItem?.unit == UnitType.liters) return 'Milliliters (ml)';
    return '';
  }

  String _getQuantityLabel() {
    if (_selectedItem == null) return 'Quantity';
    if (_useSmallUnit) {
      if (_selectedItem!.unit == UnitType.kg) return 'Quantity (g)';
      if (_selectedItem!.unit == UnitType.liters) return 'Quantity (ml)';
    }
    return 'Quantity needed per order (${_selectedItem!.unit.name})';
  }
}
