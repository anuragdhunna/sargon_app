import '/core/models/models.dart';

class LoyaltyService {
  /// Calculate points to be earned for a given spend amount
  static int calculateEarnedPoints(double spentAmount, PointRule rule) {
    if (spentAmount < rule.minBillAmount) return 0;

    // Default: ₹100 = earnValue Points (usually 1 or more)
    // Assuming earnValue is points per ₹100
    int points = ((spentAmount / 100) * rule.earnValue).floor();
    return points;
  }

  /// Calculate redemption value (Points to Rupees)
  /// Default: 10 points = ₹1 (value = 0.1)
  static double calculateRedemptionValue(
    int points, {
    double pointValue = 0.1,
  }) {
    return points * pointValue;
  }

  /// Check and return the new tier based on lifetime spend
  static LoyaltyTier? checkTierUpgrade(
    List<LoyaltyTier> tiers,
    double lifetimeSpend,
  ) {
    LoyaltyTier? highestTier;
    for (var tier in tiers) {
      if (lifetimeSpend >= tier.minSpend) {
        if (highestTier == null || tier.minSpend > highestTier.minSpend) {
          highestTier = tier;
        }
      }
    }
    return highestTier;
  }

  /// Update customer loyalty info after a transaction
  static LoyaltyInfo updateLoyaltyInfo({
    required LoyaltyInfo currentInfo,
    required int pointsEarned,
    required int pointsRedeemed,
    required double transactionAmount,
    List<LoyaltyTier> tiers = const [],
  }) {
    final int newAvailablePoints =
        currentInfo.availablePoints + pointsEarned - pointsRedeemed;
    final int newTotalPoints = currentInfo.totalPoints + pointsEarned;
    final double newLifetimeSpend =
        currentInfo.lifetimeSpend + transactionAmount;

    final newTier = checkTierUpgrade(tiers, newLifetimeSpend);

    return currentInfo.copyWith(
      availablePoints: newAvailablePoints,
      totalPoints: newTotalPoints,
      lifetimeSpend: newLifetimeSpend,
      tierId: newTier?.id ?? currentInfo.tierId,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Calculate maximum points that can be redeemed for a given bill
  static int calculateMaxRedeemablePoints(
    int availablePoints,
    PointRule rule,
    double billAmount, {
    double pointValue = 0.1,
  }) {
    // Cannot redeem more than available
    int maxPoints = availablePoints;

    // Cannot exceed bill value
    final int pointsForBill = (billAmount / pointValue).floor();
    if (maxPoints > pointsForBill) {
      maxPoints = pointsForBill;
    }

    return maxPoints;
  }
}
