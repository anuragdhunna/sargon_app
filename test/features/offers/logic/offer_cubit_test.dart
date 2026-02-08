import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/offers/domain/repositories/offer_repository.dart';
import 'package:hotel_manager/features/offers/logic/offer_cubit.dart';
import 'package:hotel_manager/features/offers/logic/offer_state.dart';

class MockOfferRepository extends Mock implements OfferRepository {}

class FakeOffer extends Fake implements Offer {}

class FakeHappyHour extends Fake implements HappyHour {}

void main() {
  late MockOfferRepository offerRepository;
  late OfferCubit offerCubit;

  setUpAll(() {
    registerFallbackValue(FakeOffer());
    registerFallbackValue(FakeHappyHour());
  });

  setUp(() {
    offerRepository = MockOfferRepository();

    // Default mock behavior
    when(
      () => offerRepository.watchOffers(),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => offerRepository.watchHappyHours(),
    ).thenAnswer((_) => Stream.value([]));

    offerCubit = OfferCubit(offerRepository: offerRepository);
  });

  tearDown(() {
    offerCubit.close();
  });

  group('OfferCubit Tests', () {
    test('initial state is OfferInitial', () {
      expect(offerCubit.state, isA<OfferInitial>());
    });

    blocTest<OfferCubit, OfferState>(
      'loadOffers emits OfferLoading and OfferLoaded',
      build: () {
        when(
          () => offerRepository.watchOffers(),
        ).thenAnswer((_) => Stream.value([]));
        when(
          () => offerRepository.watchHappyHours(),
        ).thenAnswer((_) => Stream.value([]));
        return offerCubit;
      },
      act: (cubit) => cubit.loadOffers(),
      expect: () => [isA<OfferLoading>(), isA<OfferLoaded>()],
    );

    blocTest<OfferCubit, OfferState>(
      'saveOffer calls repository',
      build: () {
        when(() => offerRepository.saveOffer(any())).thenAnswer((_) async {});
        return offerCubit;
      },
      act: (cubit) => cubit.saveOffer(
        const Offer(
          id: '1',
          name: 'Test',
          offerType: OfferType.bill,
          discountType: DiscountType.percent,
          discountValue: 10,
        ),
      ),
      verify: (_) {
        verify(() => offerRepository.saveOffer(any())).called(1);
      },
    );

    blocTest<OfferCubit, OfferState>(
      'saveHappyHour calls repository',
      build: () {
        when(
          () => offerRepository.saveHappyHour(any()),
        ).thenAnswer((_) async {});
        return offerCubit;
      },
      act: (cubit) => cubit.saveHappyHour(
        const HappyHour(
          id: '1',
          name: 'Test HH',
          applicableDays: ['Monday'],
          startTime: '10:00',
          endTime: '11:00',
          discountType: DiscountType.percent,
          discountValue: 5,
        ),
      ),
      verify: (_) {
        verify(() => offerRepository.saveHappyHour(any())).called(1);
      },
    );
  });
}
