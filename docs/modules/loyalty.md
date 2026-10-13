# Module: Loyalty Program (`loyalty`)

> **Module Path:** `lib/features/loyalty/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** Customer Retention & CRM

---

## 1. Overview & Business Domain

The `loyalty` module drives customer retention through point-earning and tiered rewards:
- **Tier Progression**: `Bronze` $\to$ `Silver` $\to$ `Gold` $\to$ `Platinum` based on lifetime spend.
- **Points Engine**: Configurable earn rate (e.g., 1 Point per ₹100 spent) and burn conversion (e.g., 1 Point = ₹1 discount).
- **Points Ledger**: Audit trail of earned points, redeemed points, and expired points.
- **Seamless POS Redemption**: Instant point redemption during bill calculation via `CustomerDetailsDialog`.

---

## 2. Architecture & File Map

```
lib/features/loyalty/
├── presentation/
│   ├── cubit/
│   │   ├── loyalty_cubit.dart         # Tier rules, point calculation, balance inquiry
│   │   └── loyalty_state.dart
│   ├── screens/
│   │   └── loyalty_dashboard_screen.dart # Tier configuration & customer points analytics
│   └── widgets/
│       ├── loyalty_tier_card.dart
│       └── points_redemption_input.dart
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Models**: `lib/core/models/crm_models.dart` (`Customer`, `LoyaltyInfo`, `LoyaltyTier`, `PointTransaction`)
- **Service**: `lib/core/services/database/database_loyalty.dart`
- **Firebase Path**: `/hotels/{hotelId}/loyalty_config` & `/hotels/{hotelId}/customers/{customerId}/points_history`

---

## 4. Cross-Module Dependencies

- **Inbound**:
  - `billing`: `BillingCubit` queries customer points and settles bill with redeemed points discount.
  - `staff_mgmt`: `CustomerListScreen` displays tier and point balance.
