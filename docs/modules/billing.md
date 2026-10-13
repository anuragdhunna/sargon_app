# Module: Billing & Invoicing (`billing`)

> **Module Path:** `lib/features/billing/`  
> **Status:** Active (Enhanced)  
> **Clean Architecture:** Yes  
> **Graphify Community:** Financial Engine & Payments

---

## 1. Overview & Business Domain

The `billing` module handles invoice calculation, tax rules, split payments, and receipt generation across all revenue streams:
- **Dynamic Tax Engine**: Configurable CGST, SGST, VAT, and dynamic Service Charge calculations via `DiscountCalculator`.
- **Offer & Promo Integration**: Real-time deduction of item-level and order-level discount codes.
- **Loyalty Point Redemption**: Direct burn of customer loyalty points against bill subtotal.
- **Multi-Tender Payments**: Split settlement across Cash, Credit/Debit Card, UPI / QR, and Bill-to-Room Folio.
- **Invoice PDF & Thermal Printing**: 80mm / 58mm ESC/POS thermal printing and A4 PDF export.

---

## 2. Architecture & File Map

```
lib/features/billing/
├── logic/
│   └── discount_calculator.dart       # Pure tax & discount calculation logic
├── presentation/ (or ui/)
│   ├── cubit/
│   │   ├── billing_cubit.dart         # Bill calculation, payment processing, persistence
│   │   └── billing_state.dart
│   ├── screens/
│   │   ├── billing_screen.dart        # Final invoice summary & payment tender screen
│   │   └── bill_history_screen.dart   # Past paid & refunded invoices
│   └── widgets/
│       ├── payment_method_selector.dart # Cash, Card, UPI, Room Folio chips
│       ├── tax_breakdown_card.dart    # Subtotal, CGST, SGST, SC, Total
│       ├── customer_details_dialog.dart # Loyalty phone lookup modal
│       └── split_payment_modal.dart   # Split bill among multiple guests
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Models**:
  - `lib/core/models/billing_models.dart` (`Bill`, `BillTaxSummary`, `Payment`, `PaymentMethod`, `TaxRule`, `ServiceChargeRule`)
- **Service**: `lib/core/services/database/database_billing.dart` & `lib/core/services/pdf_service.dart`
- **Firebase Path**: `/hotels/{hotelId}/bills/{billId}`

---

## 4. Invoice Calculation Formula

```
Item Total = ∑ (Item Price * Qty) - Item Discounts
SubTotal = Item Total - Order Level Discounts - Redeemed Loyalty Points
CGST Amount = SubTotal * (CGST % / 100)
SGST Amount = SubTotal * (SGST % / 100)
Service Charge = SubTotal * (SC % / 100)
Grand Total = SubTotal + CGST Amount + SGST Amount + Service Charge (Rounded)
```

---

## 5. Cross-Module Dependencies

- **Inbound**:
  - `orders`: `OrderHistoryScreen` invokes `BillingCubit` to bill tables.
  - `rooms`: Folio checkout triggers `BillingCubit`.
  - `events`: Banquet final settlement triggers `BillingCubit`.
- **Outbound**:
  - `table_mgmt`: Updates table to `Cleaning`.
  - `loyalty`: Awards new points to customer based on `GrandTotal`.
  - `audit`: Logs cashier transaction details.
