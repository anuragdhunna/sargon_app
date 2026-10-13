# Sargon App: Comprehensive Module Knowledge Base & Knowledge Graph System Design

- **Date:** 2026-09-14
- **Target Audience:** AI Agents & Developers
- **Status:** Approved for Implementation

---

## 1. Executive Summary & Objectives

The goal is to build an exhaustive, high-density **Module Knowledge Base** and integrated **Knowledge Graph ecosystem** across all 19 feature modules, core architecture services, and shared design system components in the Sargon App codebase.

Whenever an AI agent is tasked with building or modifying features:
1. It can instantly load the relevant `docs/modules/<module_name>.md` and understand all data contracts, state flows, rules, and entrypoints in one shot.
2. It can trace cross-screen and multi-entrypoint logic linkages (e.g., placing an order from Table Order Taking, Customer QR Ordering, Room Service, or Private Banquets) via `docs/modules/LOGIC_LINKAGE_MATRIX.md`.
3. It can query the Graphify AST Knowledge Graph (`graphify-out/graph.json` / `graphify query`) for exact class/method references.
4. It can view and leverage interactive Archify system maps (`docs/diagrams/`) for critical cross-cutting lifecycle flows.
5. It avoids known codebase bugs, anti-patterns, or architectural violations tracked in `docs/modules/ISSUES_AND_MISMATCHES.md`.

---

## 2. Directory Layout & Document Architecture

```
docs/
├── modules/
│   ├── INDEX.md                      # Master Navigation Hub & Graphify Gateway
│   ├── LOGIC_LINKAGE_MATRIX.md        # Cross-screen & Multi-entrypoint Flow Map
│   ├── ISSUES_AND_MISMATCHES.md       # Comprehensive Audit of Discovered Issues & Bugs
│   ├── core_services.md               # Auth, DatabaseService, Auditing, Multi-tenancy
│   ├── component_library.md           # lib/component/ Design System & Compliance
│   │
│   ├── attendance.md                  # Employee Clock-in/Clock-out & Hours
│   ├── audit.md                       # Activity Logs & System Auditing
│   ├── auth.md                        # Phone OTP Auth, JWT, Role-Based Access Guard
│   ├── billing.md                     # Invoices, Dynamic Taxes, Offers, Payments
│   ├── checklists.md                  # Housekeeping & Dynamic Ops Checklists
│   ├── customer_ordering.md           # Self-service QR Ordering & Menu Cart
│   ├── dashboard.md                   # KPI Aggregations & Role-based Dashboards
│   ├── events.md                      # Private Banquets, Hall Capacity, Quote Engine
│   ├── incidents.md                   # Safety/Ops Incidents & Cost Tracking
│   ├── inventory.md                   # Stock, GRN, Purchase Orders, Vendors
│   ├── loyalty.md                     # Customer Tiering, Points Earn/Burn Engine
│   ├── notifications.md               # In-app, Kitchen & Push Notifications
│   ├── offers.md                      # Discounts, Promos & Happy Hour Engine
│   ├── orders.md                      # Dine-in Taking, KDS, SLA, Course Management
│   ├── performance.md                 # Staff Analytics & Turnaround Times
│   ├── rooms.md                       # Room Bookings, Folio & Guest Lifecycle
│   ├── settings.md                    # Hotel Settings, Tax & Service Charge Configs
│   ├── staff_mgmt.md                  # Staff Profiles, Shifts & Roles
│   └── table_mgmt.md                  # Floor Plan, Join Tables, Pax Intelligence
│
└── diagrams/                          # Archify Interactive Workflow & Lifecycle Maps
    ├── order_lifecycle.html           # Multi-screen Order -> KDS -> Billing -> Housekeeping
    ├── event_booking_lifecycle.html   # Inquiry -> Halls -> Quote -> PO -> Settlement
    └── room_service_lifecycle.html    # Room Booking -> Order -> Folio -> Invoicing
```

---

## 3. Standard Module Document Specification

Every module document `docs/modules/<module_name>.md` must follow a strict, unified template:

1. **Module Overview & Business Domain**:
   - Primary Purpose, User Personas (Admin, Waiter, Cashier, Kitchen, Housekeeping, Guest).
   - Core Business Rules & Non-negotiable Constraints.
2. **Architecture & File Map**:
   - Exact Clean Architecture file paths (`data/datasources`, `data/models`, `data/repositories`, `presentation/cubit`, `presentation/screens`, `presentation/widgets`).
3. **Data Layer & Firebase Contracts**:
   - Centralized Models (`lib/core/models/`) used and JSON schema.
   - Firebase Realtime Database / Firestore paths (e.g., `hotels/{hotelId}/orders/{orderId}`).
   - Multi-tenancy isolation (`hotelId`) and Soft Delete (`isDeleted`) rules.
   - Database security rule requirements.
4. **State Management & Logic Flow**:
   - Cubit class names, State classes (`Equatable`).
   - Core Cubit methods, stream subscriptions, error handling & snackbar patterns.
5. **Cross-Module Dependency & Logic Linkage**:
   - Inbound dependencies (who calls this module).
   - Outbound dependencies (who this module triggers).
   - Multi-entrypoint interactions.
6. **Mermaid Flow Diagram**:
   - Component & data flow chart.
7. **Graphify Node Cross-References**:
   - Key AST Node IDs from `graphify-out/graph.json`.
   - Sample `graphify query` commands for agent exploration.
8. **UI & Design System Compliance**:
   - Component usage (`AppPhoneField`, `PremiumButton`, `AppCard`, `AppDropdown`, `AppTextField`).
   - Line-limit compliance check (build method < 100 lines, file < 400-600 lines).
9. **AI Agent Implementation Guide & Gotchas**:
   - Step-by-step recipes to extend/modify the module.
   - Testing rules (`bloc_test`, `mocktail`).
   - Common pitfalls & anti-patterns to avoid.

---

## 4. Multi-Entrypoint Logic Linkage Matrix Specification

`docs/modules/LOGIC_LINKAGE_MATRIX.md` maps every multi-screen workflow in detail:

| Workflow | Entrypoint Screens | Shared Cubit / Service | Underlying Entity | Downstream Side-Effects |
| :--- | :--- | :--- | :--- | :--- |
| **Order Placement** | 1. `OrderTakingScreen`<br>2. `CustomerOrderingScreen`<br>3. `RoomsScreen` (Room Service)<br>4. `EventsScreen` (Event Catering) | `OrderTakingCubit`, `CustomerOrderingCubit`, `DatabaseService.saveOrder()` | `Order`, `OrderItem` | KDS ticket creation, Table status $\to$ Occupied, SLA timer start |
| **Billing & Invoicing** | 1. `OrderHistoryScreen`<br>2. `BillingScreen`<br>3. `RoomsScreen` (Folio Checkout)<br>4. `EventsScreen` (Banquet Settlement) | `BillingCubit`, `DiscountCalculator` | `Bill`, `BillTaxSummary`, `Payment` | Table status $\to$ Billed/Cleaning, Checklist generation, Loyalty points earned |
| **Customer Creation / Linking** | 1. `CustomerDetailsDialog`<br>2. `OrderTakingScreen`<br>3. `CustomerOrderingScreen`<br>4. `RoomsScreen` (Guest Check-in)<br>5. `EventsScreen` (Host details) | `CustomerCubit`, `AuthService`, `DatabaseService.saveCustomer()` | `Customer`, `LoyaltyInfo` | Loyalty profile lookup, Spending history update |
| **Checklist Generation** | 1. Table Billed $\to$ Cleaning transition<br>2. Room Checkout $\to$ Cleaning transition<br>3. Daily Scheduled Ops | `ChecklistsCubit`, `DatabaseService.createChecklist()` | `Checklist`, `ChecklistItem` | Housekeeping push notification |
| **Incident Logging** | 1. `IncidentsScreen`<br>2. `EventsScreen` (Event incident)<br>3. `OrderTakingScreen` (Kitchen issue) | `IncidentsCubit`, `DatabaseService.saveIncident()` | `Incident` | PO/Cost adjustment, Management alert |

---

## 5. Codebase Issue & Mismatch Registry Specification

During deep scanning of all files, `docs/modules/ISSUES_AND_MISMATCHES.md` will document all findings categorized by:
1. **Critical Architecture Violations**: Direct Firebase calls inside widgets bypassing Cubit/Repository.
2. **Multi-Tenancy / Hardcoding Violations**: Hardcoded `hotelId` literals or missing `context.hotelId` propagation.
3. **Model Duplications / Legacy Data Structures**: Models defined inside features rather than `lib/core/models/`.
4. **UI Component Violations**: Standard `TextField` or unformatted phone inputs instead of `AppPhoneField`, files > 600 lines, build methods > 100 lines.
5. **Firebase Rules & Missing Path Indexes**: Database rules missing security checks or indexing for newly added feature paths.

---

## 6. Graphify & Archify Synergy

1. **Graphify (`.agents/skills/graphify`)**:
   - Used to extract AST relationships and build queryable code graphs.
   - `docs/modules/INDEX.md` and module docs link to `graphify-out/graph.json` and provide exact CLI queries.
2. **Archify (`.agents/skills/archify`)**:
   - Used to build rich, interactive, standalone HTML system and sequence maps in `docs/diagrams/` (`order_lifecycle.html`, `event_booking_lifecycle.html`, `room_service_lifecycle.html`).
   - Fully validated against Archify schemas with dark/light theme support.

---

## 7. Verification & Quality Gates

- Every module file in `lib/features/` and `lib/core/` is inspected.
- All 19 feature docs + 2 core docs + index + matrix + issue registry are generated.
- Archify diagrams pass `node .agents/skills/archify/bin/archify.mjs validate <type> <json> --quality showcase`.
- `ARCHITECTURE.md` is updated with minimal pointer to the documentation hub.
