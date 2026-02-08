import 'package:uuid/uuid.dart';
import '../../inventory_index.dart';

/// Cubit for managing purchase order logic
class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  final IInventoryRepository _repository;
  final AuditService _auditService;

  PurchaseOrderCubit({
    IInventoryRepository? repository,
    AuditService? auditService,
  }) : _repository = repository ?? InventoryRepository(),
       _auditService = auditService ?? AuditService(),
       super(PurchaseOrderInitial()) {
    loadPurchaseOrders();
  }

  final _uuid = const Uuid();
  final List<PurchaseOrder> _orders = [];

  Future<void> loadPurchaseOrders() async {
    emit(PurchaseOrderLoading());
    try {
      final orders = await _repository.getPurchaseOrders();
      _orders.clear();
      _orders.addAll(orders);
      emit(PurchaseOrderLoaded(List.from(_orders)));
    } catch (e) {
      emit(
        PurchaseOrderError('Failed to load purchase orders: ${e.toString()}'),
      );
    }
  }

  Future<void> createPurchaseOrder({
    required String vendorId,
    required String vendorName,
    required List<POLineItem> lineItems,
    DateTime? expectedDeliveryDate,
    String? notes,
    double shippingCost = 0.0,
    double taxAmount = 0.0,
    required String createdBy,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final poNumber = 'PO-${DateTime.now().year}-${_orders.length + 1}'.padLeft(
      12,
      '0',
    );

    final po = PurchaseOrder(
      id: _uuid.v4(),
      poNumber: poNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      lineItems: lineItems,
      status: POStatus.sent,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      shippingCost: shippingCost,
      taxAmount: taxAmount,
    );

    try {
      await _repository.savePurchaseOrder(po);
      _orders.insert(0, po);
      emit(PurchaseOrderLoaded(List.from(_orders)));

      _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.createPO,
        entity: 'purchase_order',
        entityId: po.id,
        description:
            'Created PO ${po.poNumber} for vendor $vendorName with ${lineItems.length} items',
      );
    } catch (e) {
      emit(
        PurchaseOrderError('Failed to create purchase order: ${e.toString()}'),
      );
    }
  }

  Future<void> cancelPurchaseOrder(
    String poId, {
    String? reason,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index != -1) {
        final updatedPO = _orders[index].copyWith(
          status: POStatus.cancelled,
          notes: reason != null ? 'Reason: $reason' : null,
        );
        await _repository.savePurchaseOrder(updatedPO);
        _orders[index] = updatedPO;
        emit(PurchaseOrderLoaded(List.from(_orders)));

        _auditService.log(
          userId: userId,
          userName: userName,
          userRole: userRole,
          action: AuditAction.update,
          entity: 'purchase_order',
          entityId: poId,
          description:
              'Cancelled PO ${updatedPO.poNumber}${reason != null ? ' - Reason: $reason' : ''}',
        );
      }
    } catch (e) {
      emit(PurchaseOrderError('Failed to cancel PO: ${e.toString()}'));
    }
  }

  Future<void> updatePOStatus(
    String poId,
    POStatus status, {
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index != -1) {
        final updatedPO = _orders[index].copyWith(status: status);
        await _repository.savePurchaseOrder(updatedPO);
        _orders[index] = updatedPO;
        emit(PurchaseOrderLoaded(List.from(_orders)));

        _auditService.log(
          userId: userId,
          userName: userName,
          userRole: userRole,
          action: AuditAction.update,
          entity: 'purchase_order',
          entityId: poId,
          description: 'Updated status of PO ${updatedPO.poNumber} to $status',
        );
      }
    } catch (e) {
      emit(PurchaseOrderError('Failed to update PO status: ${e.toString()}'));
    }
  }

  Future<void> updateLineItemReceived(
    String poId,
    String inventoryItemId,
    double quantityReceived,
  ) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index != -1) {
        final order = _orders[index];
        final lineItems = List<POLineItem>.from(order.lineItems);
        final itemIndex = lineItems.indexWhere(
          (i) => i.inventoryItemId == inventoryItemId,
        );

        if (itemIndex != -1) {
          final item = lineItems[itemIndex];
          final newReceived = item.receivedQuantity + quantityReceived;
          lineItems[itemIndex] = item.copyWith(receivedQuantity: newReceived);

          // Check if PO is fully received
          bool allReceived = true;
          for (var li in lineItems) {
            if (li.receivedQuantity < li.orderedQuantity) {
              allReceived = false;
              break;
            }
          }

          final updatedPO = order.copyWith(
            lineItems: lineItems,
            status: allReceived ? POStatus.completed : POStatus.partial,
          );

          await _repository.savePurchaseOrder(updatedPO);
          _orders[index] = updatedPO;
          emit(PurchaseOrderLoaded(List.from(_orders)));
        }
      }
    } catch (e) {
      emit(
        PurchaseOrderError(
          'Failed to update PO received quantity: ${e.toString()}',
        ),
      );
    }
  }

  PurchaseOrder? getPOById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }
}
