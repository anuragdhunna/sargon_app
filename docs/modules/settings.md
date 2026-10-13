# Module: Settings (`settings`)

> **Module Path:** `lib/features/settings/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** System Configuration

---

## 1. Overview & Business Domain

The `settings` module manages property metadata, operational rules, tax configurations, and hardware integrations:
- **Property Profile**: Hotel name, address, GSTIN/Tax ID, logo, contact phone.
- **Tax & Service Charge Rules**: CGST %, SGST %, VAT, Service Charge % configurations.
- **Printer & Hardware Config**: Thermal receipt printer IPs, Bluetooth printer pairing, KOT routing rules (Kitchen vs Bar printers).
- **Table & Room Layout Preferences**: Floor plan layouts, auto-cleaning triggers.

---

## 2. Architecture & File Map

```
lib/features/settings/
├── screens/
│   ├── settings_screen.dart           # Master settings navigation menu
│   ├── hotel_profile_screen.dart      # Business info, GSTIN, currency
│   ├── tax_settings_screen.dart       # Tax rules and service charge configuration
│   ├── printer_settings_screen.dart   # ESC/POS network & bluetooth printers
│   └── operational_rules_screen.dart  # SLA thresholds, geofence radius
└── widgets/
    ├── tax_rule_tile.dart
    ├── printer_discovery_modal.dart
    └── setting_toggle_row.dart
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Model**: `lib/core/models/hotel_model.dart` (`Hotel`, `HotelSettings`, `PrinterConfig`)
- **Service**: `lib/core/services/database/database_settings.dart`
- **Firebase Path**: `/hotels/{hotelId}` & `/hotels/{hotelId}/settings/config`
- **Security Rule**: Write access restricted to `Admin` and `Owner` roles.

---

## 4. Cross-Module Dependencies

- **Outbound**:
  - `billing`: Consumes tax and service charge percentages from `settings`.
  - `orders` (KDS): Uses kitchen printer routes configured in `settings`.
  - `attendance`: Uses geofence radius configured in `settings`.
