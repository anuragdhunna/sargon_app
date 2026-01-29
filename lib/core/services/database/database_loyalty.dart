part of '../database_service.dart';

extension DatabaseLoyalty on DatabaseService {
  DatabaseReference get loyaltyTiersRef => _ref('loyaltyTiers');
  DatabaseReference get pointRulesRef => _ref('pointRules');
  DatabaseReference get pointRedemptionsRef => _ref('pointRedemptions');

  /// Get all active loyalty tiers (one-time fetch)
  Future<List<LoyaltyTier>> getLoyaltyTiers() async {
    final snapshot = await loyaltyTiersRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => LoyaltyTier.fromJson(_toMap(e.value)))
        .toList();
  }

  /// Stream active loyalty tiers
  Stream<List<LoyaltyTier>> streamLoyaltyTiers() {
    return loyaltyTiersRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => LoyaltyTier.fromJson(_toMap(e.value)))
          .toList();
    });
  }

  /// Save or Update a Loyalty Tier
  Future<void> saveLoyaltyTier(LoyaltyTier tier) async {
    await loyaltyTiersRef.child(tier.id).set(tier.toJson());
  }

  /// Get all active point rules (one-time fetch)
  Future<List<PointRule>> getPointRules() async {
    final snapshot = await pointRulesRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => PointRule.fromJson(_toMap(e.value)))
        .toList();
  }

  /// Stream active point rules
  Stream<List<PointRule>> streamPointRules() {
    return pointRulesRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => PointRule.fromJson(_toMap(e.value)))
          .toList();
    });
  }

  /// Save or Update a Point Rule
  Future<void> savePointRule(PointRule rule) async {
    await pointRulesRef.child(rule.id).set(rule.toJson());
  }

  /// Save a point redemption
  Future<void> savePointRedemption(PointRedemption redemption) async {
    await pointRedemptionsRef.child(redemption.id).set(redemption.toJson());
  }
}
