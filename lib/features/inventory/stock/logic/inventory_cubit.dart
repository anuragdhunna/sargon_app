import 'dart:async';
import '../../inventory_index.dart';

/// Cubit for managing inventory operations
class InventoryCubit extends Cubit<InventoryState> {
  final IInventoryRepository _repository;
  final IAuditService _auditService;
  StreamSubscription? _inventorySubscription;

  InventoryCubit({
    required IInventoryRepository repository,
    IAuditService? auditService,
  }) : _repository = repository,
       _auditService = auditService ?? AuditService(),
       super(InventoryInitial());

  void loadInventory(String hotelId) {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _repository
        .streamInventory(hotelId)
        .listen(
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
    required String hotelId,
  }) async {
    try {
      await _repository.saveInventoryItem(item);

      _auditService.log(
        hotelId: hotelId,
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
    required String hotelId,
  }) async {
    try {
      if (state is InventoryLoaded) {
        final items = (state as InventoryLoaded).items;
        final item = items.firstWhere((i) => i.id == id);
        final diff = newQuantity - item.quantity;

        await _repository.updateInventoryQuantity(hotelId, id, newQuantity);

        _auditService.log(
          hotelId: hotelId,
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
    required String hotelId,
  }) async {
    try {
      await _repository.addStock(hotelId, inventoryItemId, quantity);

      if (state is InventoryLoaded) {
        final item = (state as InventoryLoaded).items.firstWhere(
          (i) => i.id == inventoryItemId,
        );
        _auditService.log(
          hotelId: hotelId,
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
