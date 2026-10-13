# Remediation Plan: Resolve Codebase Issues, Mismatches & Technical Debt

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve all unresolved issues and technical debt recorded in `docs/modules/ISSUES_AND_MISMATCHES.md` (high line count files > 500 lines, legacy in-feature model references, cubit-service decoupling, and missing unit tests), bringing all modules into 100% compliance with `ARCHITECTURE.md` and enterprise standards.

**Architecture:** Decompose oversized screens (`customer_analytics_screen.dart` and `event_details_screen.dart`) into dedicated widgets under feature `widgets/` directories; decouple `BillingCubit` settlement, loyalty awarding, and folio management into `BillingSettlementProcessor`; purge legacy model stubs and empty directories; add robust unit tests with `mocktail` for `BillingCubit`; and update `ISSUES_AND_MISMATCHES.md` and `ARCHITECTURE.md`.

**Tech Stack:** Flutter, Dart, Flutter Bloc / Cubit, Mocktail, flutter_test.

**Spec:** `docs/modules/ISSUES_AND_MISMATCHES.md` and `ARCHITECTURE.md`.

## Global Constraints
- Target maximum lines per file: 400–600 lines max (build methods strictly < 100 lines).
- Business logic NEVER lives inside widgets; widgets must be stateless where possible.
- Reusable UI widgets must be placed in `component/` (global) or `features/<module>/presentation/widgets/` or `ui/widgets/`.
- No hardcoded `hotelId` literals; use `context.hotelId` in UI and pass dynamic `hotelId` to Cubits/Services.
- Always use `AppPhoneField` for phone number inputs.
- All domain models must reside in `lib/core/models/`.
- Tests must use `mocktail` and `flutter_test`.
- Maintain 100% passing test suite and clean static analysis.

---

### Task 1: Decompose Customer Analytics Screen & Remove Hardcoded Fallbacks

**Files:**
- Create: `lib/features/staff_mgmt/ui/widgets/customer_detail_dialog.dart`
- Create: `lib/features/staff_mgmt/ui/widgets/customer_analytics_cards.dart`
- Modify: `lib/features/staff_mgmt/ui/customer_analytics_screen.dart:1-832`

**Interfaces:**
- Consumes: `Customer`, `Bill`, `Booking`, `DatabaseService`, `AuthCubit`, `context.hotelId`
- Produces: `CustomerDetailDialog(customer: customer)`, `SummaryCard(label: ..., value: ..., icon: ..., color: ...)`, `CustomerCard(customer: ..., onTap: ...)`

- [ ] **Step 1: Create `customer_analytics_cards.dart`**
Extract `_SummaryCard` and `_CustomerCard` out of `customer_analytics_screen.dart` into `lib/features/staff_mgmt/ui/widgets/customer_analytics_cards.dart`. Ensure `AppDesign`, `AppCard`, and models are cleanly imported.

- [ ] **Step 2: Create `customer_detail_dialog.dart`**
Extract `_CustomerDetailDialog`, `_DetailStatCard`, and tab builders (`_buildBillsList`, `_buildBookingsList`, `_buildLoyaltySection`) into `lib/features/staff_mgmt/ui/widgets/customer_detail_dialog.dart`.
Replace hardcoded `'default'` hotelId fallbacks with `context.hotelId` from `package:hotel_manager/core/utils/build_context_ext.dart`.

- [ ] **Step 3: Refactor `customer_analytics_screen.dart`**
Update `customer_analytics_screen.dart` to import and use `CustomerDetailDialog`, `SummaryCard`, and `CustomerCard`. Verify file line count drops from 832 to under 200 lines.

- [ ] **Step 4: Verify static analysis and existing tests**
Run: `flutter analyze lib/features/staff_mgmt/` and `flutter test`
Expected: 0 errors/warnings.

---

### Task 2: Decompose Event Details Screen into Modular Widgets

**Files:**
- Create: `lib/features/events/presentation/widgets/event_staff_assignment_widget.dart`
- Create: `lib/features/events/presentation/widgets/event_vendor_po_widget.dart`
- Create: `lib/features/events/presentation/widgets/event_incident_widget.dart`
- Create: `lib/features/events/presentation/widgets/event_pricing_dialog.dart`
- Modify: `lib/features/events/presentation/screens/event_details_screen.dart:1-986`

**Interfaces:**
- Consumes: `PrivateEvent`, `EventStaffAssignment`, `EventPO`, `EventIncident`, `EventCubit`, `context.hotelId`
- Produces: `EventStaffAssignmentWidget(event: event)`, `EventVendorPOWidget(event: event)`, `EventIncidentWidget(event: event)`, `showEventPricingDialog(context, event)`

- [ ] **Step 1: Create `event_staff_assignment_widget.dart`**
Extract `_buildStaffAssignmentSection` and `_showStaffAssignmentDialog` into `EventStaffAssignmentWidget`.
Ensure all staff selection and manager assignment logic resides in the widget.

- [ ] **Step 2: Create `event_vendor_po_widget.dart`**
Extract `_buildVendorPOSection` and `_showAddPODialog` into `EventVendorPOWidget`.
Ensure `AppPhoneField` is preserved for new vendor phone numbers.

- [ ] **Step 3: Create `event_incident_widget.dart`**
Extract `_buildIncidentSection` and `_showAddIncidentDialog` into `EventIncidentWidget`.

- [ ] **Step 4: Create `event_pricing_dialog.dart`**
Extract `_showManagePricingDialog` into `showEventPricingDialog(BuildContext context, PrivateEvent event)`.

- [ ] **Step 5: Refactor `event_details_screen.dart`**
Replace inlined dialogs and heavy sections with `EventStaffAssignmentWidget`, `EventVendorPOWidget`, `EventIncidentWidget`, and `showEventPricingDialog`.
Verify file line count drops from 986 to under 250 lines.

- [ ] **Step 6: Verify static analysis**
Run: `flutter analyze lib/features/events/`
Expected: 0 errors/warnings.

---

### Task 3: Decouple BillingCubit & Extract BillingSettlementProcessor

**Files:**
- Create: `lib/features/billing/logic/billing_settlement_processor.dart`
- Modify: `lib/features/billing/logic/billing_cubit.dart:1-592`

**Interfaces:**
- Consumes: `DatabaseService`, `AuditService`, `Bill`, `RoomFolio`, `PaymentMethod`, `PaymentStatus`
- Produces: `BillingSettlementProcessor.awardLoyaltyPoints(...)`, `BillingSettlementProcessor.attachBillToFolio(...)`, `BillingSettlementProcessor.settleFolio(...)`

- [ ] **Step 1: Create `billing_settlement_processor.dart`**
Implement `BillingSettlementProcessor` containing:
- `awardLoyaltyPoints({required DatabaseService databaseService, required String hotelId, required Bill bill})`
- `attachBillToFolio({required DatabaseService databaseService, required String hotelId, required String bookingId, required Bill bill})`
- `settleFolio({required DatabaseService databaseService, required AuditService auditService, required String hotelId, required String bookingId, required PaymentMethod method, required List<Bill> bills, String? reference})`

- [ ] **Step 2: Refactor `billing_cubit.dart`**
Update `addPayment` and `settleFolio` in `BillingCubit` to delegate folio attachment, loyalty point awards, and folio settling to `BillingSettlementProcessor`.
Verify `BillingCubit` line count reduces from 592 to under 420 lines.

- [ ] **Step 3: Verify static analysis**
Run: `flutter analyze lib/features/billing/`
Expected: 0 errors/warnings.

---

### Task 4: Clean Up Legacy In-Feature Models & Empty Directories

**Files:**
- Delete: `lib/features/inventory/stock/data/inventory_model.dart`
- Delete: `lib/features/settings/data/models/` (directory)
- Delete: `lib/features/customer_ordering/data/models/` (directory)
- Delete: `test/features/billing/logic/test.dart` (empty file)
- Modify: `lib/features/inventory/stock/index.dart:1-7`

**Interfaces:**
- Consumes: `package:hotel_manager/core/models/models.dart`
- Produces: Clean exports from `lib/features/inventory/stock/index.dart`

- [ ] **Step 1: Delete deprecated stub `inventory_model.dart` and update `index.dart`**
Delete `lib/features/inventory/stock/data/inventory_model.dart`.
Update `lib/features/inventory/stock/index.dart` to export `package:hotel_manager/core/models/models.dart` instead of the deprecated file.

- [ ] **Step 2: Remove empty model directories and scratch files**
Remove `lib/features/settings/data/models`, `lib/features/customer_ordering/data/models`, and `test/features/billing/logic/test.dart`.

- [ ] **Step 3: Verify all imports compile**
Run: `flutter analyze`
Expected: 0 errors/warnings.

---

### Task 5: Implement Comprehensive Unit Tests for BillingCubit

**Files:**
- Modify: `test/features/billing/logic/billing_cubit_test.dart:1-10`

**Interfaces:**
- Consumes: `BillingCubit`, `IBillingDatabase`, `DatabaseService`, `AuditService`, `mocktail`
- Produces: Test suite covering `loadBillingData`, `createBill`, `applyDiscount`, `addPayment`, `deleteServiceChargeRule`

- [ ] **Step 1: Write mock classes and unit test suite**
Write unit tests using `mocktail` and `bloc_test`:
- Test initial state is `BillingInitial`.
- Test `loadBillingData` emits `BillingLoaded` with tax and service charge rules.
- Test `createBill` saves bill via database service and emits updated state.
- Test `addPayment` records payment, updates payment status, and logs audit event.
- Test `deleteServiceChargeRule` calls delete on database service.

- [ ] **Step 2: Run test suite**
Run: `flutter test test/features/billing/logic/billing_cubit_test.dart`
Expected: All tests pass.

---

### Task 6: Audit & Update Documentation (`ISSUES_AND_MISMATCHES.md` & `ARCHITECTURE.md`)

**Files:**
- Modify: `docs/modules/ISSUES_AND_MISMATCHES.md`
- Modify: `ARCHITECTURE.md`

**Interfaces:**
- Consumes: Verification results of all audit tasks.
- Produces: Updated status tables and resolution logs.

- [ ] **Step 1: Update `ISSUES_AND_MISMATCHES.md`**
Mark all categories as ✅ **Resolved** (High Line Count Files refactored, Legacy In-Feature Models purged, Hardcoded literals cleaned, Phone fields standardized, Cubit unit tests 100% implemented).
Document details of extracted widgets, helper processors, and purged files.

- [ ] **Step 2: Update `ARCHITECTURE.md`**
Keep changes minimal: confirm compliance with 400-line modular widget limits and model centralization.

- [ ] **Step 3: Run full verification suite**
Run: `flutter analyze` and `flutter test`
Expected: 0 errors, 100% tests passing.
