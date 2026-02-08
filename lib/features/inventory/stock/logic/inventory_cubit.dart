import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/models/inventory_item_model.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';

/// Cubit for managing inventory operations
class InventoryCubit extends Cubit<InventoryState> {
  final DatabaseService _databaseService;
  StreamSubscription? _inventorySubscription;

  InventoryCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
      super(InventoryInitial());

  void loadInventory() {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _databaseService.streamInventory().listen(
      (items) {
        emit(InventoryLoaded(items));
      },
      onError: (error) {
        emit(InventoryError(error.toString()));
      },
    );
  }

  Future<void> addItem(
    InventoryItem item, {
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      await _databaseService.saveInventoryItem(item);

      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.create,
        entity: 'inventory',
        entityId: item.id,
        description: 'Added new inventory item: ${item.name}',
      );
    } catch (e) {
      emit(InventoryError('Failed to add item: $e'));
    }
  }

  Future<void> updateStock(
    String id,
    double newQuantity, {
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      if (state is InventoryLoaded) {
        final items = (state as InventoryLoaded).items;
        final item = items.firstWhere((i) => i.id == id);
        final diff = newQuantity - item.quantity;

        await _databaseService.updateInventoryQuantity(id, newQuantity);

        AuditService().log(
          userId: userId,
          userName: userName,
          userRole: userRole,
          action: AuditAction.update,
          entity: 'inventory',
          entityId: id,
          description:
              'Updated stock for ${item.name}: ${diff > 0 ? '+' : ''}$diff ${item.unit.name}',
        );
      }
    } catch (e) {
      emit(InventoryError('Failed to update stock: $e'));
    }
  }

  Future<void> receiveStock({
    required String inventoryItemId,
    required double quantity,
    required String grnNumber,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      await _databaseService.addStock(inventoryItemId, quantity);

      if (state is InventoryLoaded) {
        final item = (state as InventoryLoaded).items.firstWhere(
          (i) => i.id == inventoryItemId,
        );
        AuditService().log(
          userId: userId,
          userName: userName,
          userRole: userRole,
          action: AuditAction.receive,
          entity: 'inventory',
          entityId: inventoryItemId,
          description:
              'Received stock for ${item.name}: +$quantity ${item.unit.name} via $grnNumber',
          metadata: {'grnNumber': grnNumber, 'quantityReceived': quantity},
        );
      }
    } catch (e) {
      emit(InventoryError('Failed to receive stock: $e'));
    }
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}
