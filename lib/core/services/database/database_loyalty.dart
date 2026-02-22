part of '../database_service.dart';

extension DatabaseLoyalty on DatabaseService {
  CollectionReference _loyaltyTiersRef(String hotelId) =>
      _hotelDoc(hotelId).collection('loyalty_tiers');
  CollectionReference _pointRulesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('point_rules');
  CollectionReference _pointRedemptionsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('point_redemptions');

  /// Get all active loyalty tiers (one-time fetch)
  Future<List<LoyaltyTier>> getLoyaltyTiers(String hotelId) async {
    final snapshot = await _loyaltyTiersRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LoyaltyTier.fromJson(data);
    }).toList();
  }

  /// Stream active loyalty tiers
  Stream<List<LoyaltyTier>> streamLoyaltyTiers(String hotelId) {
    return _loyaltyTiersRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LoyaltyTier.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update a Loyalty Tier
  Future<void> saveLoyaltyTier(LoyaltyTier tier) async {
    await _loyaltyTiersRef(tier.hotelId).doc(tier.id).set(tier.toJson());
  }

  /// Get all active point rules (one-time fetch)
  Future<List<PointRule>> getPointRules(String hotelId) async {
    final snapshot = await _pointRulesRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PointRule.fromJson(data);
    }).toList();
  }

  /// Stream active point rules
  Stream<List<PointRule>> streamPointRules(String hotelId) {
    return _pointRulesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PointRule.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update a Point Rule
  Future<void> savePointRule(PointRule rule) async {
    await _pointRulesRef(rule.hotelId).doc(rule.id).set(rule.toJson());
  }

  /// Save a point redemption
  Future<void> savePointRedemption(PointRedemption redemption) async {
    await _pointRedemptionsRef(
      redemption.hotelId,
    ).doc(redemption.id).set(redemption.toJson());
  }
}
