import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  const CustomerLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerCubit extends Cubit<CustomerState> {
  final DatabaseService _databaseService;
  StreamSubscription? _subscription;

  CustomerCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(CustomerInitial()) {
    loadCustomers();
  }

  void loadCustomers() {
    emit(CustomerLoading());
    _subscription?.cancel();
    _subscription = _databaseService.streamCustomers().listen(
      (customers) => emit(CustomerLoaded(customers)),
      onError: (e) => emit(CustomerError(e.toString())),
    );
  }

  Future<void> saveCustomer(Customer customer) async {
    try {
      await _databaseService.saveCustomer(customer);
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
