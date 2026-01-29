import '/core/models/models.dart';

class DiscountCalculator {
  /// Calculate the tax summary for a list of orders with applied discounts
  static BillTaxSummary calculateTaxSummary({
    required List<Order> orders,
    required TaxRule? taxRule,
    ServiceChargeRule? scRule,
    List<Offer> manualDiscounts = const [],
    int loyaltyPointsRedeemed = 0,
    double pointValue = 0.1,
    RoomFolio? roomFolio, // For room guest auto-discount
  }) {
    double subTotal = 0.0;
    double totalItemDiscount = 0.0;

    // 1. Process Item & Category Discounts
    for (var order in orders) {
      for (var item in order.items) {
        double baseItemPrice =
            (item.price +
                (item.options?.fold(0.0, (s, o) => s! + o.price) ?? 0.0)) *
            item.quantity;
        subTotal += baseItemPrice;
        totalItemDiscount += item.discountAmount;
      }
    }

    double taxableAfterItemDiscounts = subTotal - totalItemDiscount;

    // 2. Process Bill-Level Discounts
    double totalBillDiscount = 0.0;
    for (var offer in manualDiscounts) {
      if (offer.offerType == OfferType.bill) {
        if (offer.discountType == DiscountType.percent) {
          totalBillDiscount +=
              taxableAfterItemDiscounts * (offer.discountValue / 100);
        } else {
          totalBillDiscount += offer.discountValue;
        }
      }
    }

    // Handle Loyalty Redemption Discount
    double loyaltyDiscount = loyaltyPointsRedeemed * pointValue;
    totalBillDiscount += loyaltyDiscount;

    double finalTaxableAmount = (taxableAfterItemDiscounts - totalBillDiscount)
        .clamp(0.0, double.infinity);

    // 3. Service Charge (calculated on post-discount subtotal)
    double scAmount = (scRule != null)
        ? (finalTaxableAmount * (scRule.percent / 100))
        : 0.0;

    // 4. GST (calculated on taxable amount + service charge)
    double taxableWithSC = finalTaxableAmount + scAmount;

    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (taxRule != null) {
      cgst = taxableWithSC * (taxRule.cgstPercent / 100);
      sgst = taxableWithSC * (taxRule.sgstPercent / 100);
      igst = taxableWithSC * (taxRule.igstPercent / 100);
    }

    double totalTax = cgst + sgst + igst;

    return BillTaxSummary(
      subTotal: subTotal,
      serviceChargeAmount: scAmount,
      taxableAmount: taxableWithSC,
      cgstAmount: cgst,
      sgstAmount: sgst,
      igstAmount: igst,
      totalDiscountAmount: totalItemDiscount + totalBillDiscount,
      totalTax: totalTax,
      grandTotal: taxableWithSC + totalTax,
    );
  }
}
