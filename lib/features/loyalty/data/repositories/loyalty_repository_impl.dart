import '/core/models/models.dart';
import '/core/services/database_service.dart';
import '../../domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final DatabaseService _databaseService;

  LoyaltyRepositoryImpl({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  Stream<List<LoyaltyTier>> watchLoyaltyTiers(String hotelId) =>
      _databaseService.streamLoyaltyTiers(hotelId);

  @override
  Future<List<LoyaltyTier>> getLoyaltyTiers(String hotelId) =>
      _databaseService.getLoyaltyTiers(hotelId);

  @override
  Future<void> saveLoyaltyTier(LoyaltyTier tier) =>
      _databaseService.saveLoyaltyTier(tier);

  @override
  Stream<List<PointRule>> watchPointRules(String hotelId) =>
      _databaseService.streamPointRules(hotelId);

  @override
  Future<List<PointRule>> getPointRules(String hotelId) =>
      _databaseService.getPointRules(hotelId);

  @override
  Future<void> savePointRule(PointRule rule) =>
      _databaseService.savePointRule(rule);

  @override
  Future<void> savePointRedemption(PointRedemption redemption) =>
      _databaseService.savePointRedemption(redemption);

  @override
  Future<void> updateCustomerLoyalty(
    String hotelId,
    String customerId,
    LoyaltyInfo loyaltyInfo,
  ) async {
    final customer = await _databaseService.getCustomer(hotelId, customerId);
    if (customer != null) {
      final updatedCustomer = customer.copyWith(loyaltyInfo: loyaltyInfo);
      await _databaseService.saveCustomer(updatedCustomer);
    }
  }
}
