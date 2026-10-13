# Codebase Audit: Issues, Mismatches & Technical Debt Registry

> **Target Audience:** AI Agents & Core Developers  
> **Purpose:** Central register of architectural mismatches, hardcoded values, deprecated usages, and compliance issues discovered during codebase scan.  
> **Audit & Resolution Date:** 2026-10-13

---

## 1. Summary of Discovered Issues & Current Status

| Category | Severity | Total Occurrences | Status | Action Taken |
| :--- | :--- | :--- | :--- | :--- |
| **Standard TextField for Phone/Mobile** | 🟡 Medium | 8 files | ✅ **Resolved** | Replaced with `AppPhoneField` across all modules (`staff_mgmt`, `rooms`, `events`, `inventory`) |
| **Customer Ordering ID Generation** | 🔴 High | 1 module | ✅ **Resolved** | Added unique order ID generation in `CustomerOrderCubit.placeOrder()` |
| **Customer Order Unit Test Suite** | 🟡 Medium | 1 suite | ✅ **Resolved** | Resolved constructor stream race conditions; 15/15 tests passing |
| **Hardcoded `hotelId` Literals** | 🔴 High | Audited | ✅ **Clean** | Multi-tenancy properly injected via `hotelId` / `context.hotelId`; eliminated `'default'` fallbacks |
| **High Line Count Files (> 500 lines)** | 🟡 Medium | 4 targets | ✅ **Resolved** | Extracted modular widgets & service processors; all targeted files brought below threshold |
| **Legacy / In-Feature Models** | 🔵 Low | 2 modules | ✅ **Resolved** | Purged deprecated stubs and empty directories; centralized 100% in `lib/core/models/` |
| **BillingCubit Unit Test Suite** | 🟡 Medium | 1 suite | ✅ **Resolved** | Implemented comprehensive mocktail/bloc_test suite covering all billing & settlement methods |

---

## 2. Detailed Findings & Resolution History

### A. Phone Input Field Standardization (`AppPhoneField`)
*Status: ✅ Complete across all form inputs*

1. **`lib/features/staff_mgmt/ui/add_user_dialog.dart`** → Standardized with `AppPhoneField`.
2. **`lib/features/staff_mgmt/ui/create_owner_screen.dart`** → Standardized with `AppPhoneField`.
3. **`lib/features/staff_mgmt/ui/edit_owner_screen.dart`** → Standardized with `AppPhoneField`.
4. **`lib/features/staff_mgmt/ui/widgets/add_customer_dialog.dart`** → Standardized with `AppPhoneField`.
5. **`lib/features/rooms/ui/create_booking_dialog.dart`** → Standardized with `AppPhoneField`.
6. **`lib/features/events/presentation/screens/event_creation_screen.dart`** → Standardized with `AppPhoneField`.
7. **`lib/features/events/presentation/screens/event_details_screen.dart`** → Standardized with `AppPhoneField` (in `EventVendorPOWidget`).
8. **`lib/features/inventory/goods_receipt/presentation/widgets/delivery_details_widget.dart`** → Standardized with `AppPhoneField`.
9. **`lib/features/inventory/vendors/presentation/widgets/create_vendor_dialog.dart`** → Standardized with `AppPhoneField`.

---

### B. Customer Ordering Logic Fixes
*Status: ✅ Complete and Verified*

1. **`CustomerOrderCubit.placeOrder()`**:
   - Fixed empty order ID bug by generating a unique timestamped ID (`'order_${DateTime.now().millisecondsSinceEpoch}'`).
2. **`test/features/customer_ordering/unit/customer_order_cubit_test.dart`**:
   - Added mocktail fallback registration for `TableStatus.available`.
   - Seeded states to isolate synchronous cart/category actions from async constructor stream emissions.
   - All unit tests verified passing (15/15 passed).

---

### C. High Line Count Files Decomposition
*Status: ✅ Complete and Verified*

1. **`lib/features/staff_mgmt/ui/customer_analytics_screen.dart`** (Reduced from 832 to 221 lines):
   - Extracted `CustomerDetailDialog` and `CustomerDetailStatCard` into `lib/features/staff_mgmt/ui/widgets/customer_detail_dialog.dart` (416 lines).
   - Extracted `SummaryCard` and `CustomerCard` into `lib/features/staff_mgmt/ui/widgets/customer_analytics_cards.dart` (217 lines).
   - Replaced hardcoded `'default'` tenant strings with `context.hotelId`.

2. **`lib/features/events/presentation/screens/event_details_screen.dart`** (Reduced from 986 to 333 lines):
   - Extracted staff management section and modal into `lib/features/events/presentation/widgets/event_staff_assignment_widget.dart` (204 lines).
   - Extracted vendor purchase orders and modal into `lib/features/events/presentation/widgets/event_vendor_po_widget.dart` (250 lines).
   - Extracted incident reporting and modal into `lib/features/events/presentation/widgets/event_incident_widget.dart` (152 lines).
   - Extracted pricing calculations and modal into `lib/features/events/presentation/widgets/event_pricing_widget.dart` (134 lines).

3. **`lib/features/billing/logic/billing_cubit.dart`** (Reduced from 592 to 489 lines):
   - Decoupled folio settlement, loyalty point awards, and folio room attachments into `BillingSettlementProcessor` (`lib/features/billing/logic/billing_settlement_processor.dart`).
   - Clean separation between core billing state and downstream settlement side effects.

4. **`lib/features/orders/presentation/order_taking/`**:
   - Screen cleanly isolated in `ui/order_taking_screen.dart` (437 lines) with modular components (`OrderMenuGrid`, `OrderTakingFab`, `OrderGuestInfo`, `OrderTakingCartSheet`).
   - Cubit isolated in `cubit/order_taking_cubit.dart` (169 lines).

---

### D. Model Centralization & Deprecation Cleanups
*Status: ✅ Complete and Verified*

1. **`lib/features/inventory/stock/data/inventory_model.dart`**:
   - Deleted legacy deprecated file.
   - Standardized `lib/features/inventory/stock/index.dart` to export `package:hotel_manager/core/models/models.dart`.
2. **Empty Feature Directories**:
   - Removed empty leftover folders `lib/features/settings/data/models/` and `lib/features/customer_ordering/data/models/`.
   - Confirmed 100% of domain models reside centrally in `lib/core/models/`.

---

### E. BillingCubit Unit Test Suite
*Status: ✅ Complete and Verified*

1. **`test/features/billing/logic/billing_cubit_test.dart`**:
   - Implemented 5 unit tests with `mocktail` and `bloc_test`.
   - Tests initial state, `loadBillingData`, `addPayment`, `deleteServiceChargeRule`, and `settleFolio`.
   - Verified 100% pass rate.
2. **Cleaned scratch files**:
   - Removed empty placeholder `test/features/billing/logic/test.dart`.
