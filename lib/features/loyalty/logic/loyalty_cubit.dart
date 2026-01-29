import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import '../domain/repositories/loyalty_repository.dart';
import 'loyalty_state.dart';

class LoyaltyCubit extends Cubit<LoyaltyState> {
  final LoyaltyRepository _loyaltyRepository;
  StreamSubscription? _tiersSubscription;
  StreamSubscription? _rulesSubscription;

  List<LoyaltyTier> _currentTiers = const [];
  List<PointRule> _currentRules = const [];

  LoyaltyCubit({required LoyaltyRepository loyaltyRepository})
    : _loyaltyRepository = loyaltyRepository,
      super(LoyaltyInitial());

  void loadLoyaltyData() {
    emit(LoyaltyLoading());

    _tiersSubscription?.cancel();
    _rulesSubscription?.cancel();

    _tiersSubscription = _loyaltyRepository.watchLoyaltyTiers().listen((tiers) {
      _currentTiers = tiers;
      _emitLoaded();
    }, onError: (e) => emit(LoyaltyError(e.toString())));

    _rulesSubscription = _loyaltyRepository.watchPointRules().listen((rules) {
      _currentRules = rules;
      _emitLoaded();
    }, onError: (e) => emit(LoyaltyError(e.toString())));
  }

  void _emitLoaded() {
    emit(LoyaltyLoaded(tiers: _currentTiers, rules: _currentRules));
  }

  @override
  Future<void> close() {
    _tiersSubscription?.cancel();
    _rulesSubscription?.cancel();
    return super.close();
  }

  Future<void> saveTier(LoyaltyTier tier) async {
    try {
      await _loyaltyRepository.saveLoyaltyTier(tier);
    } catch (e) {
      emit(LoyaltyError(e.toString()));
    }
  }

  Future<void> saveRule(PointRule rule) async {
    try {
      await _loyaltyRepository.savePointRule(rule);
    } catch (e) {
      emit(LoyaltyError(e.toString()));
    }
  }
}
