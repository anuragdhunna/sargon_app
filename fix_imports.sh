#!/bin/bash

# Bulk fix import paths from data/inventory_model.dart to core/data/inventory_model.dart

cd /Users/anuragdhunna/Downloads/Workspaces/sargon_app

# List of files to update
files=(
  "lib/features/inventory/ui/add_inventory_item_dialog.dart"
  "lib/features/inventory/ui/goods_receiving_screen.dart"
  "lib/features/inventory/ui/create_po_dialog.dart"
  "lib/features/inventory/ui/inventory_screen.dart"
  "lib/features/inventory/ui/reorder_dialog.dart"
  "lib/features/inventory/logic/inventory_cubit.dart"
  "lib/features/inventory/logic/goods_receipt_cubit.dart"
  "lib/features/inventory/logic/purchase_order_cubit.dart"
  "lib/features/inventory/logic/inventory_state.dart"
  "lib/features/inventory/data/purchase_order_model.dart"
  "lib/features/inventory/data/goods_receipt_model.dart"
)

# Replace old import with new import
for file in "${files[@]}"; do
  sed -i '' "s|import 'package:hotel_manager/features/inventory/data/inventory_model.dart'|import 'package:hotel_manager/features/inventory/core/data/inventory_model.dart'|g" "$file"
done

echo "✅ Updated ${#files[@]} files"
echo "Running flutter analyze..."
flutter analyze lib/features/inventory
