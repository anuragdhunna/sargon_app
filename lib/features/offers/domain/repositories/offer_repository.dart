import '/core/models/models.dart';

abstract class OfferRepository {
  /// Stream all active offers
  Stream<List<Offer>> watchOffers();

  /// Get all active offers
  Future<List<Offer>> getOffers();

  /// Save or update an offer
  Future<void> saveOffer(Offer offer);

  /// Stream all active happy hours
  Stream<List<HappyHour>> watchHappyHours();

  /// Get all active happy hours
  Future<List<HappyHour>> getHappyHours();

  /// Save or update a happy hour
  Future<void> saveHappyHour(HappyHour happyHour);
}
