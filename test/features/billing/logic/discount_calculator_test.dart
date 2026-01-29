import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/billing/logic/discount_calculator.dart';

void main() {
  group('DiscountCalculator Tests', () {
    late List<Order> mockOrders;
    late TaxRule mockTaxRule;
    late ServiceChargeRule mockScRule;

    setUp(() {
      mockTaxRule = const TaxRule(
        id: 'gst_5',
        name: 'GST 5%',
        cgstPercent: 2.5,
        sgstPercent: 2.5,
      );

      mockScRule = const ServiceChargeRule(
        id: 'sc_10',
        name: 'SC 10%',
        percent: 10.0,
      );

      mockOrders = [
        Order(
          id: 'o1',
          tableId: 't1',
          tableNumber: '1',
          items: [
            OrderItem(
              id: 'i1',
              menuItemId: 'm1',
              name: 'Pizza',
              price: 500.0,
              quantity: 1,
              course: CourseType.mains,
            ),
            OrderItem(
              id: 'i2',
              menuItemId: 'm2',
              name: 'Coke',
              price: 100.0,
              quantity: 2,
              course: CourseType.drinks,
              discountAmount: 40.0, // Line item total discount
              discountType: DiscountType.flat,
            ),
          ],
          timestamp: DateTime.now(),
          status: OrderStatus.served,
          paymentStatus: PaymentStatus.pending,
        ),
      ];
    });

    test(
      'calculateTaxSummary - basic calculation (No SC, No Bill Discount)',
      () {
        final summary = DiscountCalculator.calculateTaxSummary(
          orders: mockOrders,
          taxRule: mockTaxRule,
          scRule: null,
        );

        expect(summary.subTotal, 700.0);
        expect(summary.totalDiscountAmount, 40.0);
        expect(summary.taxableAmount, 660.0);
        expect(summary.totalTax, closeTo(33.0, 0.001));
        expect(summary.grandTotal, closeTo(693.0, 0.001));
      },
    );

    test('calculateTaxSummary - with Service Charge', () {
      final summary = DiscountCalculator.calculateTaxSummary(
        orders: mockOrders,
        taxRule: mockTaxRule,
        scRule: mockScRule,
      );

      expect(summary.serviceChargeAmount, 66.0);
      expect(summary.taxableAmount, 726.0);
      expect(summary.totalTax, closeTo(36.3, 0.001));
      expect(summary.grandTotal, closeTo(762.3, 0.001));
    });

    test('calculateTaxSummary - with Bill Discount (Percentage)', () {
      final manualDiscount = [
        const Offer(
          id: 'off1',
          name: '10% Off Bill',
          offerType: OfferType.bill,
          discountType: DiscountType.percent,
          discountValue: 10.0,
        ),
      ];

      final summary = DiscountCalculator.calculateTaxSummary(
        orders: mockOrders,
        taxRule: mockTaxRule,
        scRule: null,
        manualDiscounts: manualDiscount,
      );

      expect(summary.totalDiscountAmount, 40.0 + 66.0); // Item + Bill
      expect(summary.taxableAmount, 594.0);
      expect(summary.grandTotal, closeTo(623.7, 0.001));
    });

    test('calculateTaxSummary - with Loyalty Redemption', () {
      final summary = DiscountCalculator.calculateTaxSummary(
        orders: mockOrders,
        taxRule: mockTaxRule,
        scRule: null,
        loyaltyPointsRedeemed: 100,
        pointValue: 0.5, // 100 points * 0.5 = 50 off
      );

      expect(summary.totalDiscountAmount, 40.0 + 50.0);
      expect(summary.taxableAmount, 610.0);
      expect(summary.grandTotal, closeTo(640.5, 0.001));
    });

    test('calculateTaxSummary - Combination of SC, Offer, and Loyalty', () {
      final manualDiscount = [
        const Offer(
          id: 'off1',
          name: '₹10 Flat',
          offerType: OfferType.bill,
          discountType: DiscountType.flat,
          discountValue: 10.0,
        ),
      ];

      final summary = DiscountCalculator.calculateTaxSummary(
        orders: mockOrders,
        taxRule: mockTaxRule,
        scRule: mockScRule,
        manualDiscounts: manualDiscount,
        loyaltyPointsRedeemed: 20,
        pointValue: 1.0, // 20 off
      );

      expect(summary.serviceChargeAmount, 63.0);
      expect(summary.totalDiscountAmount, 40.0 + 30.0);
      expect(summary.taxableAmount, 693.0);
      expect(summary.grandTotal, closeTo(727.65, 0.001));
    });
  });
}
