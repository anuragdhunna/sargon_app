import '/core/models/models.dart';

abstract class LoyaltyRepository {
  /// Stream all active loyalty tiers
  Stream<List<LoyaltyTier>> watchLoyaltyTiers(String hotelId);

  /// Get all active loyalty tiers
  Future<List<LoyaltyTier>> getLoyaltyTiers(String hotelId);

  /// Save or update a loyalty tier
  Future<void> saveLoyaltyTier(LoyaltyTier tier);

  /// Stream all active point rules
  Stream<List<PointRule>> watchPointRules(String hotelId);

  /// Get all active point rules
  Future<List<PointRule>> getPointRules(String hotelId);

  /// Save or update a point rule
  Future<void> savePointRule(PointRule rule);

  /// Save a point redemption
  Future<void> savePointRedemption(PointRedemption redemption);

  /// Update customer loyalty info
  Future<void> updateCustomerLoyalty(
    String hotelId,
    String customerId,
    LoyaltyInfo loyaltyInfo,
  );
}
