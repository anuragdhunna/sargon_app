# Module: Audit (`audit`)

> **Module Path:** `lib/features/audit/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** Infrastructure / Compliance

---

## 1. Overview & Business Domain

The `audit` module provides tamper-evident activity and compliance logging:
- **Financial Auditing**: Voided orders, manual discounts applied, bill re-openings, cash drawer reconciliations.
- **Access & Security Logs**: User role changes, PIN resets, unauthorized route access attempts.
- **Inventory & Wastage Audits**: Manual stock adjustments, stock write-offs, goods received variance.

---

## 2. Architecture & File Map

```
lib/features/audit/
├── screens/
│   └── audit_log_screen.dart      # Filterable log viewer with timestamp, user, entity, and diff inspection
└── widgets/
    ├── audit_filter_bar.dart      # Date range, entity type, and user filter
    └── audit_detail_dialog.dart   # JSON payload & change diff modal
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Model**: `lib/core/models/audit_log.dart` (`AuditLog`, `AuditAction`, `AuditEntity`)
- **Service**: `lib/core/services/audit_service.dart`
- **Firebase Path**: `/hotels/{hotelId}/audit_logs/{logId}`
- **Security Rule**: Read-only for Managers/Admins; append-only via backend Cloud Functions or authenticated `AuditService`. **No updates or deletes allowed.**

---

## 4. State Management & Flow

```mermaid
graph LR
    Action[Business Action: Void/Discount/Edit] --> AuditS[AuditService.logActivity]
    AuditS --> FS[(Firestore /hotels/{hotelId}/audit_logs)]
    FS --> LogScreen[AuditLogScreen - StreamBuilder / Cubit]
```

---

## 5. Cross-Module Dependencies

- **Inbound**: Invoked across all modules:
  - `orders` (Order voided / items cancelled)
  - `billing` (Manual discount applied / Bill split)
  - `inventory` (Stock manual correction)
  - `staff_mgmt` (Role/Permission updated)

---

## 6. AI Agent Implementation Recipes

### How to log an audit event:
```dart
await AuditService().logActivity(
  hotelId: context.hotelId,
  userId: currentUserId,
  action: AuditAction.discountApplied,
  entity: AuditEntity.order,
  entityId: order.id,
  metadata: {
    'discountAmount': discountValue,
    'reason': reasonController.text,
    'authorizedBy': managerId,
  },
);
```
