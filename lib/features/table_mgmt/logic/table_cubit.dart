import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/models.dart';
import 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  final DatabaseService _databaseService;
  StreamSubscription? _tablesSubscription;

  TableCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(TableInitial());

  void loadTables() {
    if (state is! TableLoaded) {
      emit(TableLoading());
    }
    _tablesSubscription?.cancel();
    _tablesSubscription = _databaseService.streamTables().listen(
      (tables) {
        emit(TableLoaded(tables: tables));
      },
      onError: (e) {
        emit(TableError(message: e.toString()));
      },
    );
  }

  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    try {
      await _databaseService.updateTableStatus(tableId, status);
    } catch (e) {
      emit(TableError(message: e.toString()));
    }
  }

  /// Automated Table Suggestion Algorithm based on Pax
  List<TableEntity> suggestTables(int pax, List<TableEntity> availableTables) {
    // 1. Filter available tables
    final filtered = availableTables
        .where((t) => t.status == TableStatus.available)
        .toList();

    // 2. Prefer exact fit (min <= pax <= max)
    final exactFits = filtered
        .where((t) => t.minCapacity <= pax && t.maxCapacity >= pax)
        .toList();

    if (exactFits.isNotEmpty) {
      // Rank by least unused capacity
      exactFits.sort(
        (a, b) => (a.maxCapacity - pax).compareTo(b.maxCapacity - pax),
      );
      return exactFits;
    }

    // 3. Fallback to larger tables
    final largerTables = filtered.where((t) => t.maxCapacity >= pax).toList();
    largerTables.sort((a, b) => a.minCapacity.compareTo(b.minCapacity));

    return largerTables;
  }

  @override
  Future<void> close() {
    _tablesSubscription?.cancel();
    return super.close();
  }
}
