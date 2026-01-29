import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/models/happy_hour_model.dart';
import '../domain/repositories/offer_repository.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _offerRepository;
  StreamSubscription? _offersSubscription;
  StreamSubscription? _hhSubscription;

  List<Offer> _currentOffers = const [];
  List<HappyHour> _currentHappyHours = const [];

  OfferCubit({required OfferRepository offerRepository})
    : _offerRepository = offerRepository,
      super(OfferInitial());

  void loadOffers() {
    emit(OfferLoading());

    _offersSubscription?.cancel();
    _hhSubscription?.cancel();

    _offersSubscription = _offerRepository.watchOffers().listen((offers) {
      _currentOffers = offers;
      _emitLoaded();
    }, onError: (e) => emit(OfferError(e.toString())));

    _hhSubscription = _offerRepository.watchHappyHours().listen((happyHours) {
      _currentHappyHours = happyHours;
      _emitLoaded();
    }, onError: (e) => emit(OfferError(e.toString())));
  }

  void _emitLoaded() {
    emit(OfferLoaded(offers: _currentOffers, happyHours: _currentHappyHours));
  }

  @override
  Future<void> close() {
    _offersSubscription?.cancel();
    _hhSubscription?.cancel();
    return super.close();
  }

  Future<void> saveOffer(Offer offer) async {
    try {
      await _offerRepository.saveOffer(offer);
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> saveHappyHour(HappyHour happyHour) async {
    try {
      await _offerRepository.saveHappyHour(happyHour);
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }
}
