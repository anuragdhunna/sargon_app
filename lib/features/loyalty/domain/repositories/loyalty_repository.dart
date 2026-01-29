import '/core/models/models.dart';

abstract class LoyaltyRepository {
  /// Stream all active loyalty tiers
  Stream<List<LoyaltyTier>> watchLoyaltyTiers();

  /// Get all active loyalty tiers
  Future<List<LoyaltyTier>> getLoyaltyTiers();

  /// Save or update a loyalty tier
  Future<void> saveLoyaltyTier(LoyaltyTier tier);

  /// Stream all active point rules
  Stream<List<PointRule>> watchPointRules();

  /// Get all active point rules
  Future<List<PointRule>> getPointRules();

  /// Save or update a point rule
  Future<void> savePointRule(PointRule rule);

  /// Save a point redemption
  Future<void> savePointRedemption(PointRedemption redemption);

  /// Update customer loyalty info
  Future<void> updateCustomerLoyalty(
    String customerId,
    LoyaltyInfo loyaltyInfo,
  );
}
