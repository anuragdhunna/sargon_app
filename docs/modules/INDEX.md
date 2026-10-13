# Sargon App Module Knowledge Base & Graph Hub

> **Target Audience:** AI Agents & Core Developers  
> **Master Index:** Source of Truth for Architecture, Multi-Tenancy, and Module Linkages.

---

## 1. Fast Navigation Hub

### 🧠 Core Architecture & Global Guidelines
- [Core Architecture & Services Guide](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/core_services.md) (`DatabaseService`, `AuthService`, `AuditService`, Multi-Tenancy)
- [Component Library & Design System](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/component_library.md) (`AppPhoneField`, `PremiumButton`, `AppCard`, UI Limits)
- [Multi-Entrypoint Logic Linkage Matrix](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/LOGIC_LINKAGE_MATRIX.md) (Cross-screen flows: Orders, Billing, Customer, Housekeeping)
- [Codebase Issues & Mismatches Audit](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/ISSUES_AND_MISMATCHES.md) (Hardcoded strings, UI size violations, cleanup register)

---

## 2. All 19 Feature Modules

| # | Module | Category | Documentation Link | Primary Cubits | Key Models |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | `auth` | Security | [docs/modules/auth.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/auth.md) | `AuthCubit` | `User`, `UserRole` |
| **2** | `audit` | Compliance | [docs/modules/audit.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/audit.md) | `AuditService` | `AuditLog`, `AuditAction` |
| **3** | `attendance` | HR & Ops | [docs/modules/attendance.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/attendance.md) | `AttendanceCubit` | `AttendanceRecord` |
| **4** | `staff_mgmt` | HR & CRM | [docs/modules/staff_mgmt.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/staff_mgmt.md) | `UserCubit`, `CustomerCubit` | `User`, `Customer` |
| **5** | `dashboard` | Analytics | [docs/modules/dashboard.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/dashboard.md) | `DashboardCubit` | Realtime Aggregations |
| **6** | `performance` | Analytics | [docs/modules/performance.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/performance.md) | `PerformanceCubit` | SLA Timestamps |
| **7** | `settings` | Config | [docs/modules/settings.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/settings.md) | N/A | `Hotel`, `HotelSettings` |
| **8** | `notifications` | Alerts | [docs/modules/notifications.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/notifications.md) | `NotificationCubit` | `AppNotification` |
| **9** | `checklists` | Ops | [docs/modules/checklists.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/checklists.md) | `ChecklistCubit` | `Checklist`, `ChecklistItem` |
| **10** | `incidents` | Risk & Ops | [docs/modules/incidents.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/incidents.md) | `IncidentCubit` | `Incident` |
| **11** | `orders` | Revenue & KDS | [docs/modules/orders.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/orders.md) | `OrderTakingCubit`, `OrderCubit` | `Order`, `OrderItem` |
| **12** | `customer_ordering` | Self-Service | [docs/modules/customer_ordering.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/customer_ordering.md) | `CustomerOrderCubit` | `Order`, `MenuItem` |
| **13** | `table_mgmt` | Floor Ops | [docs/modules/table_mgmt.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/table_mgmt.md) | `TableCubit` | `TableEntity`, `TableStatus` |
| **14** | `rooms` | PMS & Lodging | [docs/modules/rooms.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/rooms.md) | `RoomCubit` | `Room`, `Booking`, `RoomFolio` |
| **15** | `billing` | Financial | [docs/modules/billing.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/billing.md) | `BillingCubit` | `Bill`, `BillTaxSummary` |
| **16** | `offers` | Marketing | [docs/modules/offers.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/offers.md) | `OfferCubit` | `Offer`, `OfferType` |
| **17** | `loyalty` | Retention | [docs/modules/loyalty.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/loyalty.md) | `LoyaltyCubit` | `LoyaltyInfo`, `LoyaltyTier` |
| **18** | `inventory` | Supply Chain | [docs/modules/inventory.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/inventory.md) | `InventoryCubit`, `PurchaseOrderCubit` | `InventoryItem`, `PurchaseOrder` |
| **19** | `events` | Banquets | [docs/modules/events.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/modules/events.md) | `EventCubit` | `PrivateEvent`, `EventQuote` |

---

## 3. Interactive Visual Architecture Maps (`docs/diagrams/`)

- [Order-to-Payment Lifecycle Map](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/diagrams/order_lifecycle.html) (Multi-screen Order $\to$ KDS $\to$ Billing $\to$ Housekeeping)
- [Room Service & Folio Lifecycle](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/diagrams/room_service_lifecycle.html) (Guest Check-in $\to$ Dining $\to$ Folio $\to$ Settlement)
- [Private Event Booking Lifecycle](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/diagrams/event_booking_lifecycle.html) (Inquiry $\to$ Halls $\to$ Quote $\to$ Vendor PO $\to$ Settlement)

---

## 4. Graphify Knowledge Graph Commands

```bash
# Query any domain topic across the AST codebase
graphify query "How does order merging work for tables?"
graphify query "How does Room Folio link dining orders to room bookings?"
graphify query "How are dynamic taxes and service charges calculated?"

# Shortest path between two classes
graphify path "OrderTakingScreen" "BillingCubit"
graphify path "CustomerOrderCubit" "KitchenScreen"

# Detailed AST entity breakdown
graphify explain "OrderTakingCubit"
graphify explain "DiscountCalculator"
```
