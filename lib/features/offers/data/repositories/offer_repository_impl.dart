import '/core/models/models.dart';
import '/core/services/database_service.dart';
import '../../domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  final DatabaseService _databaseService;

  OfferRepositoryImpl({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  Stream<List<Offer>> watchOffers(String hotelId) =>
      _databaseService.streamOffers(hotelId);

  @override
  Future<List<Offer>> getOffers(String hotelId) =>
      _databaseService.getOffers(hotelId);

  @override
  Future<void> saveOffer(Offer offer) => _databaseService.saveOffer(offer);

  @override
  Stream<List<HappyHour>> watchHappyHours(String hotelId) =>
      _databaseService.streamHappyHours(hotelId);

  @override
  Future<List<HappyHour>> getHappyHours(String hotelId) =>
      _databaseService.getHappyHours(hotelId);

  @override
  Future<void> saveHappyHour(HappyHour happyHour) =>
      _databaseService.saveHappyHour(happyHour);
}
