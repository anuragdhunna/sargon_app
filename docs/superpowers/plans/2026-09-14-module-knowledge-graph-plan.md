# Module Knowledge Base & Knowledge Graph Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a comprehensive, high-density Module Knowledge Base, multi-entrypoint Logic Linkage Matrix, Codebase Issue Registry, and interactive Graphify/Archify visual system maps across all 19 feature modules and core layers of Sargon App.

**Architecture:** Systematic file-by-file inspection of Clean Architecture layers (`data/`, `presentation/`, `domain/`, `core/models/`, `core/services/`), generating standardized, machine-readable module documentation in `docs/modules/`, cross-screen workflow matrices, Graphify AST cross-references, and validated Archify HTML flow diagrams.

**Tech Stack:** Markdown, Mermaid, Graphify (Python/AST), Archify (Node.js/JSON IR), Flutter/Dart architecture.

**Spec:** [docs/superpowers/specs/2026-09-14-module-knowledge-graph-design.md](file:///Users/anuragdhunna/Downloads/Workspaces/sargon_app/docs/superpowers/specs/2026-09-14-module-knowledge-graph-design.md)

## Global Constraints
- Target directory for module knowledge: `docs/modules/`
- Target directory for Archify interactive diagrams: `docs/diagrams/`
- Every feature module document must include: Business Domain, Clean Architecture File Map, Centralized Models (`lib/core/models/`), Firebase Paths & Tenancy (`hotelId`), State Management / Cubits, Cross-Module Linkages, Mermaid Flow, Graphify Node References, UI Design System Compliance, and AI Agent Implementation Recipes.
- `ISSUES_AND_MISMATCHES.md` must register all architectural violations, hardcoded strings, unformatted phone inputs, model duplications, and build method size limit issues.
- `LOGIC_LINKAGE_MATRIX.md` must explicitly document multi-screen workflows (e.g. Order placement from OrderTaking, CustomerOrdering, Rooms, and Events).
- Minimal update to `ARCHITECTURE.md` to point to the documentation hub.

---

### Task 1: Audit Scan of Core Services, Component Library & Feature Modules

**Files:**
- Read: `lib/core/services/**`, `lib/core/models/**`, `lib/component/**`, `lib/features/**`
- Modify: `docs/superpowers/plans/2026-09-14-module-knowledge-graph-plan.md`

**Interfaces:**
- Produces: Discovered issue list, multi-entrypoint action matrix, exact class/cubit signatures across all 19 modules.

- [ ] **Step 1: Inspect Core Services, Models, and Components**
Scan `lib/core/services/`, `lib/core/models/`, and `lib/component/` to index shared infrastructure.

- [ ] **Step 2: Inspect Feature Modules in `lib/features/`**
Scan each module (`attendance`, `audit`, `auth`, `billing`, `checklists`, `customer_ordering`, `dashboard`, `events`, `incidents`, `inventory`, `loyalty`, `notifications`, `offers`, `orders`, `performance`, `rooms`, `settings`, `staff_mgmt`, `table_mgmt`).

- [ ] **Step 3: Collate discovered issues and multi-entrypoint workflows**

---

### Task 2: Create Core Layer Documentation

**Files:**
- Create: `docs/modules/core_services.md`
- Create: `docs/modules/component_library.md`

**Interfaces:**
- Produces: Reference guides for `DatabaseService`, `AuthService`, `AuditService`, Multi-Tenancy / `hotelId`, Soft Deletes, and Design System components (`AppPhoneField`, `PremiumButton`, `AppCard`, etc.).

- [ ] **Step 1: Write `docs/modules/core_services.md`**
- [ ] **Step 2: Write `docs/modules/component_library.md`**
- [ ] **Step 3: Verify links and model references**

---

### Task 3: Create Multi-Entrypoint Logic Linkage Matrix & Issue Registry

**Files:**
- Create: `docs/modules/LOGIC_LINKAGE_MATRIX.md`
- Create: `docs/modules/ISSUES_AND_MISMATCHES.md`

**Interfaces:**
- Produces: Detailed multi-entrypoint flow diagrams and audit log of codebase issues (hardcoded IDs, model duplications, UI size limit violations).

- [ ] **Step 1: Write `docs/modules/LOGIC_LINKAGE_MATRIX.md`**
- [ ] **Step 2: Write `docs/modules/ISSUES_AND_MISMATCHES.md`**
- [ ] **Step 3: Verify all multi-entrypoint paths are fully documented**

---

### Task 4: Create Module Knowledge Documents for Operations & Management Modules (10 Modules)

**Files:**
- Create: `docs/modules/auth.md`
- Create: `docs/modules/audit.md`
- Create: `docs/modules/attendance.md`
- Create: `docs/modules/staff_mgmt.md`
- Create: `docs/modules/dashboard.md`
- Create: `docs/modules/performance.md`
- Create: `docs/modules/settings.md`
- Create: `docs/modules/notifications.md`
- Create: `docs/modules/checklists.md`
- Create: `docs/modules/incidents.md`

- [ ] **Step 1: Write `auth.md` and `audit.md`**
- [ ] **Step 2: Write `attendance.md` and `staff_mgmt.md`**
- [ ] **Step 3: Write `dashboard.md` and `performance.md`**
- [ ] **Step 4: Write `settings.md` and `notifications.md`**
- [ ] **Step 5: Write `checklists.md` and `incidents.md`**

---

### Task 5: Create Module Knowledge Documents for Revenue & Core Business Modules (9 Modules)

**Files:**
- Create: `docs/modules/orders.md`
- Create: `docs/modules/customer_ordering.md`
- Create: `docs/modules/table_mgmt.md`
- Create: `docs/modules/rooms.md`
- Create: `docs/modules/billing.md`
- Create: `docs/modules/offers.md`
- Create: `docs/modules/loyalty.md`
- Create: `docs/modules/inventory.md`
- Create: `docs/modules/events.md`

- [ ] **Step 1: Write `orders.md` and `customer_ordering.md`**
- [ ] **Step 2: Write `table_mgmt.md` and `rooms.md`**
- [ ] **Step 3: Write `billing.md` and `offers.md`**
- [ ] **Step 4: Write `loyalty.md` and `inventory.md`**
- [ ] **Step 5: Write `events.md`**

---

### Task 6: Create Master Index Hub & Graphify Gateway

**Files:**
- Create: `docs/modules/INDEX.md`
- Read: `graphify-out/graph.json`

- [ ] **Step 1: Generate `docs/modules/INDEX.md` linking all modules, matrix, issues, and Graphify AST nodes**
- [ ] **Step 2: Verify all markdown links resolve correctly**

---

### Task 7: Build & Validate Interactive Archify Visual Diagrams

**Files:**
- Create: `docs/diagrams/order_lifecycle.json` $\to$ deliver `docs/diagrams/order_lifecycle.html`
- Create: `docs/diagrams/room_service_lifecycle.json` $\to$ deliver `docs/diagrams/room_service_lifecycle.html`
- Create: `docs/diagrams/event_booking_lifecycle.json` $\to$ deliver `docs/diagrams/event_booking_lifecycle.html`

- [ ] **Step 1: Author and deliver `order_lifecycle.html` with Archify CLI**
- [ ] **Step 2: Author and deliver `room_service_lifecycle.html` with Archify CLI**
- [ ] **Step 3: Author and deliver `event_booking_lifecycle.html` with Archify CLI**
- [ ] **Step 4: Validate all Archify deliverables with zero warnings**

---

### Task 8: Update ARCHITECTURE.md & Final Verification

**Files:**
- Modify: `ARCHITECTURE.md`

- [ ] **Step 1: Add documentation section in `ARCHITECTURE.md` referencing `docs/modules/`**
- [ ] **Step 2: Verify all 24 generated documents and HTML diagrams**
