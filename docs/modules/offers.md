# Module: Offers & Discounts (`offers`)

> **Module Path:** `lib/features/offers/`  
> **Status:** Active  
> **Clean Architecture:** Yes  
> **Graphify Community:** Promotions & Revenue Growth

---

## 1. Overview & Business Domain

The `offers` module powers promotional campaigns, discount vouchers, and happy hour rules:
- **Offer Types**: Percentage Discount (e.g. 15% off), Flat Amount (e.g. ₹200 off), Item-Specific (e.g. 1+1 on Cocktails), Category Specials.
- **Validity & Scheduling**: Start/End dates, Happy Hour time windows (e.g. 4 PM - 7 PM), Minimum Bill criteria, Maximum Cap limit.
- **Dynamic Application**: Can be applied at the time of order taking or retroactively in `OrderHistoryScreen` before billing.

---

## 2. Architecture & File Map

```
lib/features/offers/
├── presentation/
│   ├── cubit/
│   │   ├── offer_cubit.dart           # Offer CRUD & validation logic
│   │   └── offer_state.dart
│   ├── screens/
│   │   └── offer_list_screen.dart     # Admin offer campaign manager
│   └── widgets/
│       ├── offer_card.dart
│       ├── create_offer_dialog.dart
│       └── coupon_code_input.dart
```

---

## 3. Data Layer & Firebase Contracts

- **Centralized Model**: `lib/core/models/promotion_models.dart` (`Offer`, `OfferType`, `DiscountType`)
- **Service**: `lib/core/services/database/database_offers.dart`
- **Firebase Path**: `/hotels/{hotelId}/offers/{offerId}`

---

## 4. Cross-Module Dependencies

- **Outbound Consumer Modules**:
  - `orders`: `ApplyOfferDialog` selects active offers and populates `OrderItem.discountAmount`.
  - `billing`: `DiscountCalculator` evaluates offer constraints during invoice generation.
  - `customer_ordering`: Validates promo codes entered by customers during self-checkout.
