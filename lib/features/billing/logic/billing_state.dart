import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

abstract class BillingState extends Equatable {
  const BillingState();
  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {
  final List<Bill> bills;
  final List<TaxRule> taxRules;
  final List<ServiceChargeRule> serviceChargeRules;
  final List<Offer> offers;

  const BillingLoaded({
    required this.bills,
    required this.taxRules,
    required this.serviceChargeRules,
    this.offers = const [],
  });

  @override
  List<Object?> get props => [bills, taxRules, serviceChargeRules, offers];
}

class BillingError extends BillingState {
  final String message;
  const BillingError(this.message);
  @override
  List<Object?> get props => [message];
}
