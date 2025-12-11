# Component Standardization Plan

**Date**: 2025-12-04  
**Purpose**: Standardize all action buttons, dropdowns, and text fields across the application

---

## Issues Identified

### 1. **Add Buttons Are Inconsistent**

| Screen | Current Implementation | Should Be |
|--------|----------------------|-----------|
| **Rooms Screen** | `ActionButton.add()` | ✅ Already using ActionButton |
| **Inventory Screen** | `IconButtonWithLabel(icon: Icons.add)` | ❌ Should use ActionButton.add() |
| **Staff Screen** | `IconButton(icon: Icon(Icons.add))` | ❌ Should use ActionButton.add() |

### 2. **Dropdowns Are Inconsistent**

Multiple implementations found:
- `DropdownButton<String>` (audit)
- `DropdownButtonFormField<T>` (inventory, rooms, PO)
- No standardized component

**Solution**: Create a reusable `AppDropdown` component (already exists but not used consistently)

### 3. **Text Fields Are Inconsistent**

Multiple implementations found:
- `CustomTextField` (form-builder based, requires `name` parameter)
- `TextField` (raw Material widget)
- `FormBuilderTextField` (form-builder widget)

**Issues with current `CustomTextField`**:
- Requires FormBuilder context
- Cannot use `onChanged` callback directly
- Requires `name` parameter even for simple use cases

**Solution**: Improve CustomTextField to support both form and non-form contexts

---

## Refactoring Plan

### Phase 1: Standardize Action Buttons ✅

#### 1.1 Inventory Screen
- **File**: `lib/features/inventory/stock/presentation/inventory_screen.dart`
- **Change**: Replace `IconButtonWithLabel(icon: Icons.add)` with `ActionButton.add()`
- **Lines**: 81-93

#### 1.2 Staff Management Screen
- **File**: `lib/features/staff_mgmt/ui/user_management_screen.dart`
- **Change**: Replace `IconButton(icon: Icon(Icons.add))` with `ActionButton.add()`
- **Lines**: 25-33

#### 1.3 Other Screens
- Scan for any other `IconButton` with `Icons.add` and standardize

---

### Phase 2: Improve TextField Component ⏳

#### 2.1 Create Enhanced CustomTextField
- **Current Issues**:
  - Requires FormBuilder context
  - Cannot use `onChanged` without FormBuilder
  - Too restrictive for simple use cases

- **Solution**: Create a new version that supports:
  - Optional FormBuilder mode
  - Direct `onChanged` callback
  - Controller support
  - Both form and non-form contexts

#### 2.2 Replace Raw TextFields
Files to update:
- `lib/features/performance/ui/employee_performance_screen.dart` (line 95)
- `lib/features/rooms/ui/create_booking_dialog.dart` (lines 393, 414)
- `lib/features/inventory/purchase_orders/presentation/po_detail_screen.dart` (line 530)
- `lib/features/orders/presentation/widgets/order_item_dialog.dart` (line 70)
- `lib/features/orders/ui/order_taking_screen.dart` (lines 377, 615)
- `lib/features/audit/ui/audit_log_screen.dart` (line 70)
- `lib/features/checklists/ui/create_checklist_screen.dart` (line 111)
- `lib/features/checklists/ui/edit_checklist_screen.dart` (line 113)
- `lib/features/checklists/ui/checklist_list_screen.dart` (line 181)

---

### Phase 3: Standardize Dropdowns ⏳

#### 3.1 Review Existing AppDropdown Component
- Check current implementation
- Ensure it supports common use cases
- Add missing features if needed

#### 3.2 Replace Raw Dropdowns
Files to update:
- `lib/features/audit/ui/audit_log_screen.dart` (line 84)
- `lib/features/inventory/goods_receipt/presentation/widgets/manual_item_card_widget.dart` (line 39)
- `lib/features/inventory/purchase_orders/presentation/widgets/po_selection_widget.dart` (line 41)  
- `lib/features/inventory/purchase_orders/presentation/create_po_dialog.dart` (line 347)
- `lib/features/rooms/ui/create_booking_dialog.dart` (line 401)

---

### Phase 4: Additional Consistency Checks ⏳

#### 4.1 Cards
- Ensure all custom Card widgets use `AppCard`
- Check staff management screen (lines 90-171)

#### 4.2 EmptyStates
- Replace simple "No data" text with `EmptyState` component
- Staff management screen (line 81)

#### 4.3 Buttons
- Replace all `FilledButton` with `PremiumButton.primary`
- Replace all `OutlinedButton` with `PremiumButton.outline`
- Inventory screen has several `FilledButton` instances (lines 160, 308, 318)

---

## Implementation Order

### Priority 1 (Start Now)
1. ✅ Standardize Add Buttons (Inventory Screen)
2. ✅ Standardize Add Buttons (Staff Screen)  
3. ✅ Replace Cards in Staff Screen with AppCard
4. ✅ Replace Empty State in Staff Screen

### Priority 2 (Next)
5. ⏳ Improve CustomTextField component
6. ⏳ Replace raw TextFields with improved CustomTextField
7. ⏳ Replace FilledButton with PremiumButton in Inventory Screen

### Priority 3 (Final)
8. ⏳ Standardize Dropdowns
9. ⏳ Final consistency check across all screens

---

## Expected Results

After completion:
- ✅ All add buttons use `ActionButton.add()`
- ✅ All cards use `AppCard`
- ✅ All empty states use `EmptyState`
- ✅ All primary buttons use `PremiumButton.primary`
- ✅ All text fields use enhanced `CustomTextField`
- ✅ All dropdowns use `AppDropdown` or standardized component
- ✅ 100% design system compliance

---

## Files to Modify

### High Priority
1. `/lib/features/inventory/stock/presentation/inventory_screen.dart`
2. `/lib/features/staff_mgmt/ui/user_management_screen.dart`
3. `/lib/component/inputs/custom_text_field.dart` (enhance)

### Medium Priority  
4. Multiple files with raw `TextField` (see Phase 2.2)
5. Multiple files with `FilledButton` (see Phase 4.3)

### Lower Priority
6. Multiple files with raw dropdowns (see Phase 3.2)
