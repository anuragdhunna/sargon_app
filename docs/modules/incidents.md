# Module: Incidents (`incidents`)

> **Module Path:** `lib/features/incidents/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** Operations & Risk Management

---

## 1. Overview & Business Domain

The `incidents` module tracks property damages, customer disputes, safety hazards, and inventory loss:
- **Incident Categorization**: Breakage/Damage, Food Quality Dispute, Security, Medical/Safety, Equipment Breakdown.
- **Financial Assessment**: Estimated financial loss and insurance/vendor recovery claims.
- **Resolution Tracking**: Investigating manager, corrective actions taken, resolution status (`Open`, `Investigating`, `Resolved`, `Closed`).

---

## 2. Architecture & File Map

```
lib/features/incidents/
├── presentation/
│   ├── cubit/
│   │   ├── incident_cubit.dart
│   │   └── incident_state.dart
│   ├── screens/
│   │   └── incident_report_screen.dart # Log view & incident reporting form
│   └── widgets/
│       ├── incident_card.dart
│       ├── severity_chip.dart
│       └── report_incident_dialog.dart
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Model**: `lib/core/models/operations_models.dart` (`Incident`, `IncidentSeverity`, `IncidentStatus`)
- **Service**: `lib/core/services/database/database_incidents.dart`
- **Firebase Path**: `/hotels/{hotelId}/incidents/{incidentId}`

---

## 4. Cross-Module Dependencies

- **Inbound Sources**:
  - `events`: Banquet hall damages or guest disputes.
  - `inventory`: Bulk spoilage or delivery breakage.
  - `orders`: Food return or customer complaint.
- **Outbound**:
  - `audit`: Permanent record for compliance.
  - `notifications`: Alerts General Manager for `High` or `Critical` severity incidents.
