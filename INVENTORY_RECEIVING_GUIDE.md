# Inventory Receiving System - Quick Reference

## Quick Access

From the **Inventory Screen**, you now have two new buttons in the app bar:

1. **📋 Purchase Orders** - Manage all purchase orders
2. **📦 Receive Goods** - Receive inventory from vendors

## Common Workflows

### Creating a Purchase Order

1. Navigate to **Inventory Screen**
2. Tap **Purchase Orders** button
3. Tap **+ New PO** (FAB)
4. Fill in:
   - Vendor name
   - Expected delivery date
   - Add items (select from inventory, enter quantity and price)
5. Tap **Create PO**

### Receiving Goods Against a PO

1. Navigate to **Inventory Screen**
2. Tap **Receive Goods** button
3. Select PO from dropdown
4. Enter delivery details:
   - Delivery person name and phone
   - Invoice number
5. Capture proof:
   - Tap to capture bill photo
   - Tap to capture goods photo
6. For each item:
   - Enter quantity received
   - Check quality OK
   - Add notes if needed
7. Tap **Submit & Update Inventory**

### Receiving Goods Without PO

1. Navigate to **Inventory Screen**
2. Tap **Receive Goods** button
3. Tap **Receive without PO**
4. Follow same steps as above (feature coming soon for item selection)

### Viewing GRN History

1. Navigate to **Purchase Orders** screen
2. Tap on any PO to view details
3. Related GRNs are shown in the detail view
4. Tap on GRN to view full receipt details

## Key Features

✅ **Partial Receiving** - Receive items in multiple batches
✅ **Proof of Delivery** - Capture bill and goods photos
✅ **Quality Checks** - Mark quality status per item
✅ **Auto Inventory Update** - Stock updated automatically
✅ **Full Audit Trail** - All actions logged with user and timestamp
✅ **PO Status Tracking** - Automatic status updates (sent → partial → completed)

## File Structure

```
lib/features/inventory/
├── data/
│   ├── vendor_model.dart          # Vendor information
│   ├── purchase_order_model.dart  # PO and line items
│   ├── goods_receipt_model.dart   # GRN and receiving data
│   └── inventory_model.dart       # Existing inventory items
├── logic/
│   ├── purchase_order_cubit.dart  # PO management
│   ├── goods_receipt_cubit.dart   # Receiving logic
│   └── inventory_cubit.dart       # Enhanced with receiveStock()
└── ui/
    ├── purchase_orders_screen.dart   # PO list
    ├── create_po_dialog.dart         # Create new PO
    ├── po_detail_screen.dart         # PO details
    ├── goods_receiving_screen.dart   # Receive goods
    ├── grn_history_screen.dart       # GRN history
    └── inventory_screen.dart         # Enhanced with navigation
```

## Mock Data Available

- 3 Sample POs (completed, partial, pending)
- 2 Sample GRNs
- Ready for testing all scenarios
