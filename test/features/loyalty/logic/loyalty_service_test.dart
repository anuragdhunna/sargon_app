import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_service.dart';

void main() {
  group('LoyaltyService Tests', () {
    late PointRule mockRule;

    setUp(() {
      mockRule = const PointRule(
        id: 'r1',
        earnType: PointEarnType.bill_amount,
        earnValue: 1.0, // 1 point per 100 rupees
        minBillAmount: 100.0,
      );
    });

    test('calculateEarnedPoints - below minimum amount returns 0', () {
      final points = LoyaltyService.calculateEarnedPoints(50.0, mockRule);
      expect(points, 0);
    });

    test('calculateEarnedPoints - correctly calculates points', () {
      // 1000 / 100 * 1 = 10 points
      final points = LoyaltyService.calculateEarnedPoints(1000.0, mockRule);
      expect(points, 10);
    });

    test('calculateRedemptionValue - correctly converts points to value', () {
      // 200 points * 0.5 = 100 rupees
      final value = LoyaltyService.calculateRedemptionValue(
        200,
        pointValue: 0.5,
      );
      expect(value, 100.0);
    });

    test('calculateMaxRedeemablePoints - respects rule limits', () {
      // bill is 100, point value is 0.5 -> max points for bill is 200.
      final max = LoyaltyService.calculateMaxRedeemablePoints(
        300,
        mockRule,
        100.0,
        pointValue: 0.5,
      );
      expect(max, 200);

      // respects available
      final max2 = LoyaltyService.calculateMaxRedeemablePoints(
        50,
        mockRule,
        1000.0,
      );
      expect(max2, 50);
    });

    test('checkTierUpgrade - upgrades tier when spend threshold reached', () {
      const currentTier = LoyaltyTier(
        id: 'silver',
        name: 'Silver',
        minSpend: 0,
        earnMultiplier: 1.0,
      );
      const nextTier = LoyaltyTier(
        id: 'gold',
        name: 'Gold',
        minSpend: 5000,
        earnMultiplier: 1.25,
      );

      final tiers = [currentTier, nextTier];

      final upgradedTier = LoyaltyService.checkTierUpgrade(tiers, 6000.0);
      expect(upgradedTier?.id, 'gold');

      final baseTier = LoyaltyService.checkTierUpgrade(tiers, 4000.0);
      expect(baseTier?.id, 'silver');
    });

    test('updateLoyaltyInfo - correctly updates points and spend', () {
      final info = const LoyaltyInfo(
        tierId: 'silver',
        totalPoints: 500,
        availablePoints: 400,
        lifetimeSpend: 2000.0,
      );

      // Earn 50 points, spend 100
      final updated = LoyaltyService.updateLoyaltyInfo(
        currentInfo: info,
        pointsEarned: 50,
        pointsRedeemed: 100,
        transactionAmount: 1000.0,
      );

      expect(updated.totalPoints, 550); // 500 + 50
      expect(updated.availablePoints, 350); // 400 + 50 - 100
      expect(updated.lifetimeSpend, 2000.0 + 1000.0);
    });
  });
}
