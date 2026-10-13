# Component Library & Design System Guide

> **Target Audience:** AI Agents & Frontend Developers  
> **Source Directory:** `lib/component/`  
> **Compliance Level:** Strict Enterprise

---

## 1. Overview & Golden Rules

All UI elements must utilize components from `lib/component/`. Direct usage of primitive unstyled widgets (such as `ElevatedButton`, `TextField`, or manual `Card` containers) is **strictly forbidden**.

### Golden Rules:
1. **Phone Input Requirement**: Every single phone or mobile number input across the entire application **MUST** use `AppPhoneField` (`lib/component/inputs/app_phone_field.dart`). Never use `TextField` or `TextFormField` for phone numbers.
2. **Buttons**: Use `PremiumButton` or variants from `lib/component/buttons/`.
3. **Cards & Containers**: Wrap surfaces in `AppCard` (`lib/component/cards/app_card.dart`).
4. **Form Controls**: Use `AppTextField`, `AppDropdown`, `AppDatePicker` from `lib/component/inputs/`.
5. **Feedback & Alerts**: Use `CustomSnackbar` and `ConfirmationDialog` from `lib/component/feedback/` and `lib/component/dialogs/`.
6. **Build Method Limits**: Keep `build` methods under **100 lines**; extract sub-widgets into dedicated private or reusable widget classes.

---

## 2. Component Directory Index

```
lib/component/
├── badges/        # Status tags, priority chips, SLA indicators
├── buttons/       # PremiumButton, IconButton, SegmentedControl
├── cards/         # AppCard, MetricCard, SummaryCard
├── dialogs/       # ConfirmationDialog, InputModal, FilterDialog
├── feedback/      # CustomSnackbar, AppLoader, EmptyStateView
├── headers/       # PageHeader, SectionHeader, TableFloorHeader
├── inputs/        # AppPhoneField, AppTextField, AppDropdown, SearchBar
├── layouts/       # ResponsiveGrid, ThreeColumnLayout, SafeContainer
├── states/        # LoadingShimmer, ErrorWidget, EmptyPlaceholder
└── tooltips/      # Informational popovers, KPI helpers
```

---

## 3. Core Component Reference & API Signatures

### A. Phone Input (`AppPhoneField`)
- **File**: `lib/component/inputs/app_phone_field.dart`
- **Usage**:
```dart
AppPhoneField(
  controller: _phoneController,
  label: 'Guest Mobile Number',
  isRequired: true,
  initialCountryCode: 'IN',
  onChanged: (phone) {
    // phone.completeNumber provides E.164 formatted string (+919876543210)
  },
  validator: (phone) => phone == null || phone.number.isEmpty ? 'Required' : null,
)
```

### B. Standard Buttons (`PremiumButton`)
- **File**: `lib/component/buttons/premium_button.dart`
- **Variants**: `primary`, `secondary`, `outline`, `danger`, `ghost`
- **Usage**:
```dart
PremiumButton(
  label: 'Place Order',
  icon: Icons.check_circle_outline,
  isLoading: state.isSubmitting,
  variant: ButtonVariant.primary,
  onPressed: () => context.read<OrderTakingCubit>().submitOrder(),
)
```

### C. Standard Surface Card (`AppCard`)
- **File**: `lib/component/cards/app_card.dart`
- **Usage**:
```dart
AppCard(
  padding: const EdgeInsets.all(AppSpacing.md),
  elevation: 2.0,
  onTap: () => _handleCardTap(),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Table 04', style: AppTypography.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      TableStatusBadge(status: table.status),
    ],
  ),
)
```

### D. Input Fields (`AppTextField` & `AppDropdown`)
- **Files**: `lib/component/inputs/app_text_field.dart`, `lib/component/inputs/app_dropdown.dart`
- **Usage**:
```dart
AppTextField(
  controller: _notesController,
  label: 'Order Notes',
  hint: 'e.g. Less spicy, Extra napkins',
  maxLines: 2,
)

AppDropdown<String>(
  label: 'Course Category',
  value: selectedCourse,
  items: ['Starters', 'Main Course', 'Desserts', 'Beverages'],
  onChanged: (val) => setState(() => selectedCourse = val),
)
```

### E. Dialogs & Modals (`ConfirmationDialog`)
- **File**: `lib/component/dialogs/confirmation_dialog.dart`
- **Usage**:
```dart
ConfirmationDialog.show(
  context,
  title: 'Cancel Order?',
  message: 'Are you sure you want to void this active order? This action cannot be undone.',
  confirmLabel: 'Void Order',
  isDanger: true,
  onConfirm: () => context.read<OrderCubit>().voidOrder(orderId),
);
```

---

## 4. Design Tokens & Styling Constants

- **Typography**: Access via `Theme.of(context).textTheme` or `AppTypography`.
- **Colors**: Access via `Theme.of(context).colorScheme` or `AppColors`. Never use hardcoded `Color(0xFF...)`.
- **Spacing**: Use standard spacing steps:
  - `AppSpacing.xs` = 4.0
  - `AppSpacing.sm` = 8.0
  - `AppSpacing.md` = 16.0
  - `AppSpacing.lg` = 24.0
  - `AppSpacing.xl` = 32.0
