import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/inventory/purchase_orders/presentation/purchase_orders_screen.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';
import 'package:hotel_manager/features/inventory/stock/presentation/add_inventory_item_dialog.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/goods_receiving_screen.dart';
import 'package:hotel_manager/features/inventory/stock/presentation/reorder_dialog.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/grn_tracking_screen.dart';

import 'package:hotel_manager/component/buttons/icon_button_with_label.dart';
import 'package:hotel_manager/component/headers/section_header.dart';
import 'package:hotel_manager/component/badges/status_badge.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/component/cards/premium_info_card.dart';
import 'package:hotel_manager/component/inputs/premium_search_bar.dart';
import 'package:hotel_manager/component/feedback/custom_snackbar.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium Inventory Management Screen
///
/// Features:
/// - Low stock alerts with reorder functionality
/// - Search and filter
/// - Premium card-based UI
/// - Interactive animations
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const String routeName = '/inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  ItemCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButtonWithLabel(
            icon: Icons.receipt_long,
            label: 'Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PurchaseOrdersScreen(),
                ),
              );
            },
            isVertical: true,
            iconSize: 20,
            fontSize: 10,
          ),
          const SizedBox(width: AppDesign.space2),
          IconButtonWithLabel(
            icon: Icons.inventory_2,
            label: 'Receive',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoodsReceivingScreen(),
                ),
              );
            },
            isVertical: true,
            iconSize: 20,
            fontSize: 10,
          ),
          const SizedBox(width: AppDesign.space2),
          IconButtonWithLabel(
            icon: Icons.add,
            label: 'Add',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddInventoryItemDialog(),
              );
            },
            isVertical: true,
            iconSize: 20,
            fontSize: 10,
          ),
          const SizedBox(width: AppDesign.space2),
          IconButtonWithLabel(
            icon: Icons.local_shipping,
            label: 'GRN',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GRNTrackingScreen(),
                ),
              );
            },
            isVertical: true,
            iconSize: 20,
            fontSize: 10,
          ),
          const SizedBox(width: AppDesign.space2),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = state.items;
          final lowStockItems = items.where((i) => i.isLowStock).toList();

          // Apply search and filter
          var filteredItems = items.where((item) {
            final matchesSearch =
                _searchQuery.isEmpty ||
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.category.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
            final matchesCategory =
                _selectedCategory == null || item.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDesign.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Search Bar
                PremiumSearchBar(
                  hintText: 'Search inventory...',
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  showFilter: true,
                  onFilterTap: () => _showFilterDialog(context),
                ),
                const SizedBox(height: AppDesign.space6),

                /// Low Stock Alerts
                if (lowStockItems.isNotEmpty) ...[
                  SectionHeader(
                    icon: Icons.warning,
                    title: 'Low Stock Alerts',
                    subtitle: '${lowStockItems.length} items need reordering',
                    iconColor: AppDesign.error,
                    action: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ReorderDialog(preselectedItems: lowStockItems),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: const Text('Reorder All'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppDesign.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.space4,
                          vertical: AppDesign.space2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDesign.space4),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: lowStockItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppDesign.space3),
                      itemBuilder: (context, index) {
                        return _buildLowStockCard(
                          context,
                          lowStockItems[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDesign.space8),
                ],

                /// All Items Section
                SectionHeader(
                  icon: Icons.inventory_2,
                  title: 'All Items',
                  subtitle: '${filteredItems.length} items',
                  action: _selectedCategory != null
                      ? TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Filter'),
                        )
                      : null,
                ),
                const SizedBox(height: AppDesign.space4),

                if (filteredItems.isEmpty)
                  EmptyState(
                    icon: Icons.search_off,
                    title: 'No Items Found',
                    message: 'Try adjusting your search or filters',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = null;
                      });
                    },
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDesign.space3),
                    itemBuilder: (context, index) {
                      return _buildItemCard(context, filteredItems[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLowStockCard(BuildContext context, InventoryItem item) {
    return PremiumInfoCard(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ReorderDialog(preselectedItems: [item]),
        );
      },
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: AppDesign.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.warning, color: AppDesign.error, size: 20),
              ],
            ),
            const SizedBox(height: AppDesign.space2),
            Text(
              item.category.name.toUpperCase(),
              style: AppDesign.labelSmall.copyWith(color: AppDesign.neutral500),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.quantity.toStringAsFixed(0),
                  style: AppDesign.headlineMedium.copyWith(
                    color: AppDesign.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDesign.space1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item.unit.name,
                    style: AppDesign.bodySmall.copyWith(color: AppDesign.error),
                  ),
                ),
              ],
            ),
            Text(
              'Min: ${item.minQuantity.toStringAsFixed(0)}',
              style: AppDesign.labelSmall.copyWith(color: AppDesign.neutral500),
            ),
            const SizedBox(height: AppDesign.space3),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ReorderDialog(preselectedItems: [item]),
                  );
                },
                icon: const Icon(Icons.shopping_cart, size: 16),
                label: const Text('Reorder'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesign.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.space3,
                    vertical: AppDesign.space2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, InventoryItem item) {
    return PremiumInfoCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesign.space3),
            decoration: BoxDecoration(
              color: item.isLowStock
                  ? AppDesign.error.withOpacity(0.1)
                  : AppDesign.neutral100,
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            ),
            child: Icon(
              _getCategoryIcon(item.category),
              color: item.isLowStock ? AppDesign.error : AppDesign.neutral600,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDesign.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppDesign.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${item.category.name.toUpperCase()} • ₹${item.pricePerUnit}/${item.unit.name}',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral500,
                  ),
                ),
              ],
            ),
          ),
          if (item.isLowStock)
            StatusBadge.error(label: 'Low Stock', showGlow: false),
          const SizedBox(width: AppDesign.space3),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _adjustStock(context, item, -1),
                color: AppDesign.error,
                iconSize: 20,
              ),
              Text(
                '${item.quantity.toStringAsFixed(0)} ${item.unit.name}',
                style: AppDesign.titleSmall.copyWith(
                  color: item.isLowStock
                      ? AppDesign.error
                      : AppDesign.neutral900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _adjustStock(context, item, 1),
                color: AppDesign.success,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return Icons.restaurant;
      case ItemCategory.beverage:
        return Icons.local_bar;
      case ItemCategory.housekeeping:
        return Icons.cleaning_services;
      case ItemCategory.maintenance:
        return Icons.build;
      case ItemCategory.other:
        return Icons.spa;
    }
  }

  void _adjustStock(BuildContext context, InventoryItem item, double delta) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    final newQuantity = (item.quantity + delta).clamp(0.0, double.infinity);
    context.read<InventoryCubit>().updateStock(
      item.id,
      newQuantity,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
    );

    CustomSnackbar.showSuccess(
      context,
      'Updated ${item.name} quantity to ${newQuantity.toStringAsFixed(0)}',
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDesign.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Category', style: AppDesign.titleLarge),
            const SizedBox(height: AppDesign.space4),
            Wrap(
              spacing: AppDesign.space2,
              runSpacing: AppDesign.space2,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...ItemCategory.values.map((category) {
                  return FilterChip(
                    label: Text(category.name.toUpperCase()),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
