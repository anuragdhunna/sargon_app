import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import '../../inventory_index.dart';
import 'inventory_state.dart';

/// Cubit for managing inventory operations
class InventoryCubit extends Cubit<InventoryState> {
  final IInventoryRepository _repository;
  final AuditService _auditService;
  StreamSubscription? _inventorySubscription;

  InventoryCubit({
    required IInventoryRepository repository,
    AuditService? auditService,
  }) : _repository = repository,
       _auditService = auditService ?? AuditService(),
       super(InventoryInitial());

  void loadInventory() {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _repository.streamInventory().listen(
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
      await _repository.saveInventoryItem(item);

      _auditService.log(
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

        await _repository.updateInventoryQuantity(id, newQuantity);

        _auditService.log(
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
      await _repository.addStock(inventoryItemId, quantity);

      if (state is InventoryLoaded) {
        final item = (state as InventoryLoaded).items.firstWhere(
          (i) => i.id == inventoryItemId,
        );
        _auditService.log(
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
