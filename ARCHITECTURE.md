# Sargon App Architecture & Development Guidelines

> **Target Audience:** AI Agents & Developers
> **Purpose:** Source of Truth for Architecture, Modules, and Coding Standards.
> **Last Updated:** 2025-12-04

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
│   ├── services/       # Global services (API, Storage, etc.)
│   ├── ui/             # Main layouts, global UI wrappers
│   └── widgets/        # Global primitive widgets
├── features/           # Feature Modules (See Module Structure)
│   ├── auth/
│   ├── dashboard/
│   ├── inventory/
│   ├── orders/
│   └── ...
├── theme/              # App Theme & Colors
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
| **rooms** | Room management and status | Active |
| **staff_mgmt** | Staff profiles and management | Active |

### Order Module Features (Production-Ready)
- **Order Taking**: Responsive menu grid (2-3 columns), category filtering, search
- **Order Merging**: Auto-merges items for pending orders on same table (industry standard)
- **Order Notes**: Item-level notes + overall order-level notes (e.g., "Birthday", "Rush")
- **Order History**: Complete history with KDS status tracking, timestamps, and notes display
- **Cart Management**: Proper clearing after order placement, edit/remove items before submission

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

---

## 7. AI Agent Instructions

- **Read First:** Always read this file before starting a task to understand where files belong.
- **Update:** If you add a new module or significantly change the architecture, **UPDATE THIS FILE**.
- **No Duplication:** Do not create `product_list.dart` if `inventory/stock/ui/stock_list.dart` already exists. Check the file tree first.
- **Style:** Follow the "Premium Design" aesthetic. Use shadows, rounded corners, and smooth animations.

