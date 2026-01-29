import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_cubit.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_state.dart';

class MockLoyaltyRepository extends Mock implements LoyaltyRepository {}

class FakeLoyaltyTier extends Fake implements LoyaltyTier {}

class FakePointRule extends Fake implements PointRule {}

void main() {
  late MockLoyaltyRepository loyaltyRepository;
  late LoyaltyCubit loyaltyCubit;

  setUpAll(() {
    registerFallbackValue(FakeLoyaltyTier());
    registerFallbackValue(FakePointRule());
  });

  setUp(() {
    loyaltyRepository = MockLoyaltyRepository();

    // Default mock behavior
    when(
      () => loyaltyRepository.watchLoyaltyTiers(),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => loyaltyRepository.watchPointRules(),
    ).thenAnswer((_) => Stream.value([]));

    loyaltyCubit = LoyaltyCubit(loyaltyRepository: loyaltyRepository);
  });

  tearDown(() {
    loyaltyCubit.close();
  });

  group('LoyaltyCubit Tests', () {
    test('initial state is LoyaltyInitial', () {
      expect(loyaltyCubit.state, isA<LoyaltyInitial>());
    });

    blocTest<LoyaltyCubit, LoyaltyState>(
      'loadLoyaltyData emits LoyaltyLoading and LoyaltyLoaded',
      build: () {
        when(
          () => loyaltyRepository.watchLoyaltyTiers(),
        ).thenAnswer((_) => Stream.value([]));
        when(
          () => loyaltyRepository.watchPointRules(),
        ).thenAnswer((_) => Stream.value([]));
        return loyaltyCubit;
      },
      act: (cubit) => cubit.loadLoyaltyData(),
      expect: () => [isA<LoyaltyLoading>(), isA<LoyaltyLoaded>()],
    );

    blocTest<LoyaltyCubit, LoyaltyState>(
      'saveTier calls repository',
      build: () {
        when(
          () => loyaltyRepository.saveLoyaltyTier(any()),
        ).thenAnswer((_) async {});
        return loyaltyCubit;
      },
      act: (cubit) => cubit.saveTier(
        const LoyaltyTier(
          id: '1',
          name: 'Silver',
          minSpend: 1000,
          earnMultiplier: 1.0,
        ),
      ),
      verify: (_) {
        verify(() => loyaltyRepository.saveLoyaltyTier(any())).called(1);
      },
    );

    blocTest<LoyaltyCubit, LoyaltyState>(
      'saveRule calls repository',
      build: () {
        when(
          () => loyaltyRepository.savePointRule(any()),
        ).thenAnswer((_) async {});
        return loyaltyCubit;
      },
      act: (cubit) => cubit.saveRule(
        const PointRule(
          id: '1',
          earnType: PointEarnType.bill_amount,
          earnValue: 1,
        ),
      ),
      verify: (_) {
        verify(() => loyaltyRepository.savePointRule(any())).called(1);
      },
    );
  });
}
