import '/core/models/models.dart';
import '/core/services/database_service.dart';
import '../../domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  final DatabaseService _databaseService;

  OfferRepositoryImpl({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  Stream<List<Offer>> watchOffers() => _databaseService.streamOffers();

  @override
  Future<List<Offer>> getOffers() => _databaseService.getOffers();

  @override
  Future<void> saveOffer(Offer offer) => _databaseService.saveOffer(offer);

  @override
  Stream<List<HappyHour>> watchHappyHours() =>
      _databaseService.streamHappyHours();

  @override
  Future<List<HappyHour>> getHappyHours() => _databaseService.getHappyHours();

  @override
  Future<void> saveHappyHour(HappyHour happyHour) =>
      _databaseService.saveHappyHour(happyHour);
}
