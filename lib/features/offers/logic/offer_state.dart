import 'package:equatable/equatable.dart';
import '/core/models/models.dart';

abstract class OfferState extends Equatable {
  const OfferState();

  @override
  List<Object?> get props => [];
}

class OfferInitial extends OfferState {}

class OfferLoading extends OfferState {}

class OfferLoaded extends OfferState {
  final List<Offer> offers;
  final List<HappyHour> happyHours;

  const OfferLoaded({required this.offers, required this.happyHours});

  @override
  List<Object?> get props => [offers, happyHours];
}

class OfferError extends OfferState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object?> get props => [message];
}
