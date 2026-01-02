import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {}

class TableLoading extends TableState {}

class TableLoaded extends TableState {
  final List<TableEntity> tables;

  const TableLoaded({required this.tables});

  @override
  List<Object?> get props => [tables];
}

class TableError extends TableState {
  final String message;

  const TableError({required this.message});

  @override
  List<Object?> get props => [message];
}
