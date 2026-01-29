# Sargon App Architecture & Development Guidelines

> **Target Audience:** AI Agents & Developers
> **Purpose:** Source of Truth for Architecture, Modules, and Coding Standards.
> **Last Updated:** 2026-01-26

## 1. Architectural Overview

The application follows a **Feature-First, Clean Architecture** approach using **Flutter** and **Cubits** for state management.

### Core Principles
- **Separation of Concerns:** UI, Business Logic (Cubits), and Data (Repositories/Services) are strictly separated.
- **Modularity:** Features are isolated in `lib/features/`.
- **Reusability:** Shared UI components live in `lib/component/` or `lib/core/widgets/`.
- **Scalability:** Code is structured to support enterprise-level growth without tight coupling.

---

## 2. Directory Structure

```
lib/
├── component/          # Shared Design System (Buttons, Cards, Inputs, etc.)
│   ├── buttons/
│   ├── cards/
│   ├── inputs/
│   └── ...
├── core/               # Global core functionality
│   ├── auth/           # Authentication logic & guards
│   ├── models/         # ⭐ CENTRALIZED MODELS (all domain models)
│   ├── navigation/     # App routing
│   ├── services/       # Global services (Firebase, Auth, Database, etc.)
│   ├── ui/             # Main layouts, global UI wrappers
│   └── widgets/        # Global primitive widgets
├── features/           # Feature Modules (See Module Structure)
│   ├── auth/
│   ├── dashboard/
│   ├── inventory/
│   ├── orders/
│   ├── table_mgmt/     # Table seating, status, groups, pax intelligence
│   └── ...
├── theme/              # App Theme & Colors
├── firebase_options.dart  # Firebase configuration (auto-generated)
└── main.dart           # Entry point
```

---

## 3. Feature Module Structure

Every feature in `lib/features/` should follow this internal structure:

```
features/<feature_name>/
├── data/               # Data Layer
│   ├── datasources/    # API calls, local DB access
│   ├── models/         # JSON serialization (extends Domain Entities)
│   └── repositories/   # Repository implementations
├── domain/             # Domain Layer (Optional for simpler apps, but preferred)
│   ├── entities/       # Pure Dart classes
│   └── repositories/   # Repository interfaces
├── presentation/ (or ui/)
│   ├── cubit/          # State Management (Cubit + State)
│   ├── screens/        # Full page widgets (Scaffold)
│   └── widgets/        # Feature-specific widgets
└── <feature>_index.dart # Barrel file for clean exports (Optional)
```

**Note:** Some legacy modules might use `ui` directly containing screens and widgets. New refactors should prefer `presentation/screens` and `presentation/widgets`.

---

## 4. Existing Modules (Do Not Duplicate)

Before creating a new file, check if the functionality belongs to an existing module:

| Module | Description | Status |
| :--- | :--- | :--- |
| **attendance** | Employee attendance tracking | Active |
| **audit** | Audit logs and system checks | Active |
| **auth** | Authentication (Login, Role Guard) | Active |
| **checklists** | Operational checklists | Active |
| **dashboard** | Main landing screen, stats, widgets | Active |
| **incidents** | Incident reporting and management | Active |
| **inventory** | Stock, Goods Receipt, POs, Vendors | **Refactored** (Sub-modules: `stock`, `goods_receipt`, `purchase_orders`, `vendors`) |
| **orders** | Order taking, order history, KDS sync | **Enhanced**: Order merging for same table, overall order notes, responsive 3-column grid, real-time order history with KDS status |
| **performance** | Staff performance metrics | Active |
| **rooms** | Room management and status | **Refactored** (Cubit -> Repository pattern) |
| **staff_mgmt** | Staff profiles and management | Active |
| **table_mgmt** | Table seating, status, groups, pax intelligence | Active |
| **billing** | Invoicing, taxes, offers, and payments | **Enhanced**: Dynamic tax/service charge, offer application, loyalty redemption |
| **offers** | Discount management, happy hours | Active |
| **loyalty** | Point earning and tier management | Active |
| **customers** | CRM, analytics, spending history | Active |

### Order Module Features (Production-Ready)
- **Order Taking**: Refactored to Clean Architecture with dedicated `OrderTakingCubit`. Features responsive menu grid, category filtering, search, and reactive cart management.
- **Order Merging**: Auto-merges items for pending orders on same table (industry standard)
- **Order Notes**: Item-level notes + overall order-level notes (e.g., "Birthday", "Rush")
- **Digital KDS**: Production-grade Kitchen Display System with course-wise firing, ticket-based view, and priority sorting.
- **SLA Tracking**: Real-time monitoring of preparation times with delay alerts and progress bars.
- **Order Merging**: Auto-merges items for pending orders on same table (industry standard).
- **Course Intelligence**: Granular management of Starters, Mains, Desserts, and Drinks.
- **Pax Intelligence**: Guest count tracking per order for analytics and seating optimization.

---

## 5. Coding Standards & Rules (Strict)

### A. Naming Conventions
- **Files:** `snake_case.dart` (e.g., `user_profile_screen.dart`)
- **Classes:** `PascalCase` (e.g., `UserProfileScreen`)
- **Variables/Functions:** `camelCase` (e.g., `fetchUserData`)
- **Constants:** `kPascalCase` or `SCREAMING_SNAKE_CASE` (e.g., `kDefaultPadding`)

### B. Widget Guidelines
- **Stateless Preferred:** Use `StatelessWidget` unless local state (like `TextEditingController`) is absolutely necessary.
- **Extract Widgets:** If a `build` method exceeds **100 lines**, extract parts into smaller widgets.
- **Const Constructors:** Always use `const` where possible.
- **Theming:** Access colors/styles via `Theme.of(context)` or `AppColors`. **Do not hardcode hex values.**

### C. State Management (Cubit)
- **Logic Isolation:** Business logic **NEVER** lives in the UI.
- **Pattern:** UI -> Cubit -> Repository -> Data Source.
- **State:** Use `Equatable` for States to ensure efficient rebuilds.

### D. Routing
- **Static Routes:** Every screen must have a `static const String routeName = '/...';`.
- **Navigation:** Use `Navigator.pushNamed` with the static constant.

---

## 6. Expert Refactoring Guidelines

When modifying code, apply these expert-level practices:

1.  **DRY (Don't Repeat Yourself):** If you see duplicated UI code, move it to `lib/component/` or a shared widget.
2.  **SOLID Principles:**
    *   **S:** Classes should have a single responsibility.
    *   **O:** Open for extension, closed for modification.
    *   **D:** Depend on abstractions (Repositories), not concretions.
3.  **Performance:**
    *   Use `const` widgets.
    *   Avoid rebuilding the entire screen; use `BlocBuilder` on specific sections.
    *   Cache expensive computations.
4.  **Error Handling:**
    *   Catch errors in the Repository layer.
    *   Return `Either<Failure, Success>` or throw custom Exceptions caught by the Cubit.
    *   Show user-friendly error messages (Snackbars/Dialogs) via `BlocListener`.

### E. Testing Standards (Established Jan 2026)
- **Unit Testing:** Mandatory for Cubits. Use `bloc_test` and `mocktail`.
- **Mocks:** Dependencies (Repositories/Services) must be mocked using `Mock` classes.
- **Async Control:** Use `StreamController` in tests to simulate real-time data flow (e.g., Firebase streams).
- **Validation:** Always verify that dependency methods were called using `verify(...).called(n)`.

---

## 7. AI Agent Instructions

- **Read First:** Always read this file before starting a task to understand where files belong.
- **Update:** If you add a new module or significantly change the architecture, **UPDATE THIS FILE**.
- **No Duplication:** Do not create `product_list.dart` if `inventory/stock/ui/stock_list.dart` already exists. Check the file tree first.
- **Style:** Follow the "Premium Design" aesthetic. Use shadows, rounded corners, and smooth animations.

### Table & KDS Intelligence (SARGON)
- **Table Entity**: Physical tables are first-class citizens with seating capacities and joinable logic.
- **Automated Lifecycle**: Tables transition automatically through states: `Available` -> `Occupied` -> `Billed` -> `Cleaning`. Transition to `Cleaning` auto-creates housekeeping checklists via Firebase; completion reverts status to `Available`.
- **Pax-Based Table Suggestion**: Algorithmically suggests the best table fit based on guest count to maximize floor yield.
- **Production KDS**: Item-level status tracking (Pending -> Fired -> Preparing -> Ready -> Served) with SLA enforcement.
- **Dynamic Offer Engine**: Real-time offer application from Order History with intelligent discount logic.

---

## 8. 🚀 Quick Reference: Reusable Components & Flows

> **PURPOSE:** Before creating ANY new component, **CHECK THIS LIST** to see if it already exists and can be reused or extended.

### 🎨 Design System Components (`lib/component/`)

| Component | Path | Usage | Props |
| :--- | :--- | :--- | :--- |
| **PremiumButton** | `component/buttons/premium_button.dart` | Primary, Secondary, Outline, Danger buttons | `label`, `onPressed`, `isLoading`, `icon` |
| **AppCard** | `component/cards/app_card.dart` | Consistent card wrapper | `child`, `padding`, `elevation` |
| **AppTextField** | `component/inputs/app_text_field.dart` | Styled text input | `controller`, `label`, `hint`, `validator` |
| **AppDropdown** | `component/inputs/app_dropdown.dart` | Dropdown selector | `items`, `value`, `onChanged` |
| **CustomSnackbar** | Direct static call | Success, Error, Warning toasts | `CustomSnackbar.showSuccess(context, msg)` |

### 🔀 Reusable Dialogs & Modals

| Dialog | Path | When to Use | Key Props |
| :--- | :--- | :--- | :--- |
| **ApplyOfferDialog** | `features/orders/presentation/widgets/apply_offer_dialog.dart` | Select and apply offers to orders | `orderId`, `onApply(Offer)` |
| **CustomerDetailsDialog** | `features/billing/ui/widgets/customer_details_dialog.dart` | Capture customer for loyalty | `onConfirm(Customer?)` |
| **ConfirmationDialog** | `component/dialogs/confirmation_dialog.dart` | Yes/No prompts | `title`, `message`, `onConfirm` |

### 📄 Full-Page Screens Reference

| Screen | Route | Purpose | Key Features |
| :--- | :--- | :--- | :--- |
| **DashboardScreen** | `/dashboard` | Landing page with KPIs | Role-based metrics, real-time refresh |
| **TableDashboardScreen** | `/tables` | Visual table floor plan | Table status, capacity, join tables |
| **OrderTakingScreen** | `/order-taking` | Create new order | Menu grid, category filter, auto-merge for same table |
| **OrderHistoryScreen** | `/order-history` | View all orders | Real-time KDS status, Apply Offer, Generate Bill, Payment |
| **KitchenScreen** | `/kitchen` | Kitchen Display System | Course firing, SLA tracking, priority sorting |
| **BillingScreen** | `/billing` | Generate bill | Tax calculation, offer application, loyalty redemption |
| **RoomsScreen** | `/rooms` | Room bookings | Guest check-in, room service link |

### 🔁 Common Business Flows (MUST FOLLOW)

#### Flow 1: Dine-In Order to Payment
```
TableDashboardScreen → Select Table
  ↓
OrderTakingScreen → Add Menu Items → Save Order
  ↓
KitchenScreen → Fire Courses → Mark Ready → Serve
  ↓
OrderHistoryScreen → Apply Offer (Optional) → Generate Bill
  ↓
CustomerDetailsDialog → Link Customer for Loyalty (OR Skip)
  ↓
BillingCubit.createBill() → Tax Calculation with Discounts
  ↓
OrderHistoryScreen → Add Payment
  ↓
PaymentDialog → Select Method → Process
  ↓
Table Status → Cleaning → Auto-Create Checklist
```

#### Flow 2: Room Service Order
```
RoomsScreen → Select Room with Active Booking
  ↓
OrderTakingScreen → Add Items (roomId & bookingId auto-linked)
  ↓
[Same KDS flow as Dine-In]
  ↓
Generate Bill → Customer Details SKIPPED (fetch from Booking)
  ↓
BillingCubit.createBill(bookingId, customerId from booking)
  ↓
Payment → Bill to Room (adds to Folio)
```

#### Flow 3: Apply Offer to Order
```
OrderHistoryScreen → Select Order (status: Pending)
  ↓
Tap "Apply Offer" Button
  ↓
ApplyOfferDialog → Shows Active Offers
  ↓
Select Offer → OrderCubit.applyOfferToOrder(orderId, offer)
  ↓
OrderCubit Calculates Discount → Updates OrderItem.discountAmount
  ↓
Saves Order to Firebase
  ↓
UI Re-renders → Shows Discounted Price in Order Items
  ↓
Tax Summary (Est.) → Reflects Discount in Grand Total
```

### 🛠️ Core Services Reference

| Service | Path | Key Methods |
| :--- | :--- | :--- |
| **DatabaseService** | `core/services/database_service.dart` | `streamOrders()`, `saveOrder()`, `updateOrderStatus()` |
| **AuthService** | `core/services/auth_service.dart` | `signInWithPhone()`, `verifyOTP()` |
| **DiscountCalculator** | `features/billing/logic/discount_calculator.dart` | `calculateTaxSummary(orders, taxRule, scRule, manualDiscounts)` |
| **AuditService** | `core/services/audit_service.dart` | `log(userId, action, entity, metadata)` |

### 📊 Centralized Models (`lib/core/models/`)

**DO NOT create duplicate models. All domain models live here.**

| Model | File | Critical Fields |
| :--- | :--- | :--- |
| **Order** | `order_model.dart` | `id`, `tableId`, `roomId`, `bookingId`, `customerId`, `items[]`, `status`, `paymentStatus` |
| **OrderItem** | `order_model.dart` | `id`, `menuItemId`, `name`, `price`, `quantity`, `discountAmount`, `discountType`, `kdsStatus` |
| **Bill** | `bill_model.dart` | `id`, `orderIds[]`, `customerId`, `redeemedPoints`, `taxSummary`, `payments[]`, `grandTotal` |
| **BillTaxSummary** | `bill_model.dart` | `subTotal`, `cgstAmount`, `sgstAmount`, `serviceChargeAmount`, `totalDiscountAmount`, `grandTotal` |
| **Offer** | `offer_model.dart` | `id`, `name`, `offerType`, `discountType`, `discountValue`, `maxDiscountAmount`, `applicableItemIds[]` |
| **Customer** | `customer_model.dart` | `id`, `name`, `phone`, `email`, `loyaltyInfo` |
| **LoyaltyInfo** | `loyalty_model.dart` | `tierId`, `totalPoints`, `availablePoints`, `lifetimeSpend` |
| **Booking** | `booking_model.dart` | `id`, `roomId`, `guestName`, `phone`, `email`, `customerId` |

---

## 9. ⚠️ Common Issues & Solutions

| Problem | Root Cause | Solution |
| :--- | :--- | :--- |
| **Offer not applying** | `discountAmount` not persisted in OrderItem | Ensure `OrderCubit.applyOfferToOrder()` saves updated order with `item.discountAmount` |
| **Tax not reflecting discount** | `DiscountCalculator` not receiving updated order items | Pass order with `item.discountAmount` populated to `calculateTaxSummary()` |
| **Customer dialog shows for room orders** | Logic doesn't check `order.roomId != null` | In `OrderHistoryScreen`, skip dialog if `order.roomId` exists; fetch customer from booking |
| **Skip button doesn't close dialog** | `onConfirm(null)` doesn't dismiss dialog | Must call `Navigator.pop(context)` inside `onConfirm` callback |
| **Dashboard TypeError** | Firebase RTDB returns `LinkedMap` instead of `Map` | Use safe casting: `Map<dynamic, dynamic>.from(value)` in `_mapList()` |
| **Loyalty points not calculated** | `BillingCubit.createBill()` missing `customerId` | Ensure `customerId` is passed and loyalty logic runs post-bill |

---

## 10. Development Workflow Checklist

Before committing ANY feature:
- [ ] Checked this Quick Reference for existing components
- [ ] Verified no duplicate models in `lib/core/models/`
- [ ] Updated `database.rules.json` for new Firebase paths
- [ ] Added unit tests for new Cubits
- [ ] Ran `flutter analyze` with zero errors
- [ ] Tested on mobile and web
- [ ] Updated ARCHITECTURE.md if introducing new patterns

---
