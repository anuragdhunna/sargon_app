# Module: Staff Management (`staff_mgmt`)

> **Module Path:** `lib/features/staff_mgmt/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** HR & User Administration

---

## 1. Overview & Business Domain

The `staff_mgmt` module administers hotel and restaurant employees, access roles, and customer CRM profiles:
- **Employee Lifecycle**: Onboarding, role assignment (`Admin`, `Manager`, `Waiter`, `Chef`, `Housekeeping`), PIN allocation.
- **Shift Scheduling**: Assigning staff to floor sections (Tables, Kitchen, Rooms, Banquets).
- **Customer Directory**: CRM profile search, contact info, total spend, and loyalty tier viewing.
- **Owner & Multi-Property Admin**: Registering new property owners and managers.

---

## 2. Architecture & File Map

```
lib/features/staff_mgmt/
├── presentation/
│   ├── cubit/
│   │   ├── user_cubit.dart                # Staff CRUD & list state
│   │   ├── customer_cubit.dart            # CRM customer directory state
│   │   ├── owner_registration_cubit.dart  # Multi-property onboarding
│   │   └── staff_mgmt_state.dart
│   ├── screens/
│   │   ├── staff_list_screen.dart         # Employee directory with search & role filter
│   │   ├── staff_detail_screen.dart       # Staff profile, stats, permissions
│   │   ├── add_staff_screen.dart          # New employee registration
│   │   ├── customer_list_screen.dart      # CRM customer registry
│   │   └── customer_detail_screen.dart    # Customer lifetime orders, loyalty points
│   └── widgets/
│       ├── staff_card.dart
│       ├── role_selector_chip.dart
│       └── add_staff_dialog.dart
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Models**:
  - `lib/core/models/user_model.dart` (`User`, `UserRole`, `StaffShift`)
  - `lib/core/models/crm_models.dart` (`Customer`, `LoyaltyInfo`)
- **Services**: `lib/core/services/database/database_users.dart`, `database_customers.dart`
- **Firebase Paths**:
  - `/hotels/{hotelId}/users/{userId}`
  - `/hotels/{hotelId}/customers/{customerId}`

---

## 4. State Management (`UserCubit` & `CustomerCubit`)

```mermaid
graph TD
    StaffUI[StaffListScreen] --> UserCubit[UserCubit]
    UserCubit --> DBUsers[DatabaseUsers.streamUsers]
    DBUsers --> FS[(Firestore /hotels/{hotelId}/users)]

    CRMUI[CustomerListScreen] --> CustCubit[CustomerCubit]
    CustCubit --> DBCust[DatabaseCustomers.streamCustomers]
    DBCust --> FS2[(Firestore /hotels/{hotelId}/customers)]
```

---

## 5. Cross-Module Dependencies

- **Inbound**:
  - `orders` & `billing`: Read `CustomerCubit` during customer linking.
  - `table_mgmt`: Assigns active waiters from `UserCubit` to tables.
- **Outbound**:
  - `auth`: Creates new Firebase Auth credentials when onboarding staff.
  - `attendance`: Feeds user profiles into clock-in lists.

---

## 6. AI Agent Implementation Recipes

### Phone Field Mandate:
When modifying `add_staff_screen.dart` or `add_staff_dialog.dart`, **always** use `AppPhoneField` (`lib/component/inputs/app_phone_field.dart`) with country code support rather than standard `TextField`.
