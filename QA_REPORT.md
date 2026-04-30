# QA Audit Report - Sargon App
**Date**: April 19, 2026
**Auditor**: Antigravity (QA Expert)

## Executive Summary
This audit focuses on adherence to the established **MEMORY[user_global]** coding standards, UI/UX guidelines, and architectural patterns. While the core architecture is sound, several critical violations of the "Clean Code" and "Reusable Components" rules were identified, particularly regarding phone number fields and file length limits.

---

## 1. High Priority Violations (Immediate Action Required)

### 🚨 Phone Number Field Rule Violation
**Rule**: *"Use @lib/component/inputs/app_phone_field.dart Phone Number Field Every Where instead of using normal text field"*
- **AddCustomerDialog**: `lib/features/staff_mgmt/ui/widgets/add_customer_dialog.dart` uses `AppTextField` for phone input (Line 74).
- **CreateBookingDialog**: `lib/features/rooms/ui/create_booking_dialog.dart` uses `AppTextField` for `guestPhone` (Line 167).

### 🚨 File Length Limit Violation
**Rule**: *"No file's number of line must increase 400-600, if it is increasing start create new files for widgets."*
- **EventCreationScreen**: `lib/features/events/presentation/screens/event_creation_screen.dart` - **762 lines**.
- **CreateBookingDialog**: `lib/features/rooms/ui/create_booking_dialog.dart` - **744 lines**.
- **PODetailScreen**: `lib/features/inventory/purchase_orders/presentation/po_detail_screen.dart` - **696 lines**.
- **DashboardScreen**: `lib/features/dashboard/ui/dashboard_screen.dart` - **691 lines**.

---

## 2. Coding Standards & Naming Violations

### 📁 Inconsistent Folder Structure
**Guideline**: *"Place reusable widgets under: features/<module>/presentation/widgets/"*
- Most features still use `ui/` instead of `presentation/` (e.g., `lib/features/rooms/ui`, `lib/features/staff_mgmt/ui`). This contradicts the implied "presentation" structure and previous refactoring goals.

### 🏗️ Extraction of Reusable Widgets
**Guideline**: *"Extract UI portions into reusable widgets when they repeat."*
- **DashboardScreen**: Contains 6+ private widget classes (`_KPIItem`, `_SalesRow`, etc.) that should be moved to `widgets/` files to reduce file complexity.
- **PODetailScreen**: Heavily reliant on private helper methods (`_buildHeaderCard`, `_buildLineItemsSection`) instead of dedicated widget classes.

---

## 3. UI/UX & Component Guidelines

### 🧱 Non-Standard Component Usage
**Rule**: *"Use custom reusable components: PrimaryButton, AppTextField, AppCard, AppLoader, AppErrorWidget"*
- **EventCreationScreen**: Uses raw `DropdownButtonFormField` (Lines 171, 215, 727) instead of `AppDropdown`.
- **CreateBookingDialog**: Uses raw `TextField` for accompanying guest details (Lines 674, 678, 682) instead of `AppTextField`.
- **PODetailScreen**: Uses raw `TextField` for cancellation reason (Line 656).

### 🏷️ Hardcoded Business Rules
**Rule**: *"NEVER EVER HARDCODE BUSINESS RULES"*
- **EventCreationScreen**: Hardcoded fallback tax rules (GST 5%, GST 18%) directly in the UI code (Lines 199-212). These should ideally be managed via a config service or Firebase Remote Config.

---

## 4. Logical & State Management Observations

### 🧠 Logic Inside Widgets
- **PODetailScreen**: Contains conditional logic for status updates and dialog triggers directly in the `build` method and helper functions, rather than delegating purely to the `Cubit`.
- **CreateBookingDialog**: Contains date difference and price calculation logic (`_getNights`, `_calculateTotal`) which should ideally reside in the `RoomModel` or `RoomCubit` to keep the UI "pure".

---

## Recommended Next Steps
1.  **Refactor**: Split `EventCreationScreen` and `CreateBookingDialog` into smaller functional widgets.
2.  **Standardize Inputs**: Replace all phone-related `AppTextField` with `AppPhoneField`.
3.  **Component Audit**: Replace raw `DropdownButtonFormField` with `AppDropdown`.
4.  **Folder Renaming**: Complete the transition from `ui/` to `presentation/` across all modules.
