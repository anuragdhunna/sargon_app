import 'package:equatable/equatable.dart';
import '/core/models/models.dart';

abstract class LoyaltyState extends Equatable {
  const LoyaltyState();

  @override
  List<Object?> get props => [];
}

class LoyaltyInitial extends LoyaltyState {}

class LoyaltyLoading extends LoyaltyState {}

class LoyaltyLoaded extends LoyaltyState {
  final List<LoyaltyTier> tiers;
  final List<PointRule> rules;

  const LoyaltyLoaded({required this.tiers, required this.rules});

  @override
  List<Object?> get props => [tiers, rules];
}

class LoyaltyError extends LoyaltyState {
  final String message;

  const LoyaltyError(this.message);

  @override
  List<Object?> get props => [message];
}
