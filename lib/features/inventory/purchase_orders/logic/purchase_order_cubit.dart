import 'dart:async';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/models.dart';
import '../../inventory_index.dart';
import '../../../notifications/data/repositories/notification_repository.dart';

class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  final IInventoryRepository _repository;
  final INotificationRepository _notificationRepository;
  final IAuditService _auditService;
  final List<PurchaseOrder> _orders = [];
  final _uuid = const Uuid();
  StreamSubscription? _subscription;

  PurchaseOrderCubit({
    required IInventoryRepository repository,
    INotificationRepository? notificationRepository,
    IAuditService? auditService,
  }) : _repository = repository,
       _notificationRepository =
           notificationRepository ?? NotificationRepository(),
       _auditService = auditService ?? AuditService(),
       super(PurchaseOrderInitial());

  void loadPurchaseOrders(String hotelId) {
    emit(PurchaseOrderLoading());
    _subscription?.cancel();
    _subscription = _repository
        .streamPurchaseOrders(hotelId)
        .listen(
          (orders) {
            _orders.clear();
            _orders.addAll(orders);
            _orders.sort(
              (a, b) => (b.createdOn ?? DateTime(0)).compareTo(
                a.createdOn ?? DateTime(0),
              ),
            );
            emit(PurchaseOrderLoaded(List.from(_orders)));
          },
          onError: (e) {
            emit(
              PurchaseOrderError(
                'Failed to load purchase orders: ${e.toString()}',
              ),
            );
          },
        );
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
    required String hotelId,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final sequence = (_orders.length + 1).toString().padLeft(4, '0');
    final poNumber = 'PO-$dateStr-$sequence';

    final settings = await _repository.getAppSettings(hotelId);
    final status = settings.requiresPOApproval
        ? POStatus.pendingApproval
        : POStatus.sent;

    final po = PurchaseOrder(
      id: _uuid.v4(),
      hotelId: hotelId,
      poNumber: poNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      lineItems: lineItems,
      status: status,
      createdOn: DateTime.now(),
      createdBy: createdBy,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      shippingCost: shippingCost,
      taxAmount: taxAmount,
    );

    try {
      await _repository.savePurchaseOrder(po);

      if (status == POStatus.pendingApproval) {
        await _notificationRepository.addNotification(
          hotelId,
          NotificationModel(
            hotelId: hotelId,
            id: _uuid.v4(),
            title: 'PO Approval Required',
            body:
                'Purchase Order ${po.poNumber} from $vendorName requires approval.',
            type: NotificationType.inventory,
            createdOn: DateTime.now(),
            targetRoute: '/inventory/purchase-orders/${po.id}',
          ),
        );
      }

      _orders.insert(0, po);
      emit(PurchaseOrderLoaded(List.from(_orders)));

      _auditService.log(
        hotelId: hotelId,
        performedBy: userId,
        performedByRole: userRole,
        action: AuditAction.createPO,
        targetUserId: po.id,
        description:
            'Created PO ${po.poNumber} ($status) for vendor $vendorName with ${lineItems.length} items',
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
    required String hotelId,
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
          hotelId: hotelId,
          performedBy: userId,
          performedByRole: userRole,
          action: AuditAction.update,
          targetUserId: poId,
          description:
              'Cancelled PO ${updatedPO.poNumber}${reason != null ? ' - Reason: $reason' : ''}',
        );
      }
    } catch (e) {
      emit(PurchaseOrderError('Failed to cancel PO: ${e.toString()}'));
    }
  }

  Future<void> receivePOLineItem(
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
          (li) => li.inventoryItemId == inventoryItemId,
        );

        if (itemIndex != -1) {
          final item = lineItems[itemIndex];
          lineItems[itemIndex] = item.copyWith(
            receivedQuantity: item.receivedQuantity + quantityReceived,
          );

          // Check if PO should be marked as completed or partial
          var allReceived = true;
          var anyReceived = false;
          for (var li in lineItems) {
            if (li.receivedQuantity < li.orderedQuantity && !li.isCancelled) {
              allReceived = false;
            }
            if (li.receivedQuantity > 0) {
              anyReceived = true;
            }
          }

          POStatus newStatus = order.status;
          if (allReceived) {
            newStatus = POStatus.completed;
          } else if (anyReceived) {
            newStatus = POStatus.partial;
          }

          final updatedPO = order.copyWith(
            lineItems: lineItems,
            status: newStatus,
          );
          await _repository.savePurchaseOrder(updatedPO);
          _orders[index] = updatedPO;
          emit(PurchaseOrderLoaded(List.from(_orders)));
        }
      }
    } catch (e) {
      emit(
        PurchaseOrderError('Failed to receive PO line item: ${e.toString()}'),
      );
    }
  }

  Future<void> updatePOStatus(
    String poId,
    POStatus status, {
    required String userId,
    required String userName,
    required String userRole,
    required String hotelId,
  }) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index != -1) {
        final updatedPO = _orders[index].copyWith(status: status);
        await _repository.savePurchaseOrder(updatedPO);
        _orders[index] = updatedPO;
        emit(PurchaseOrderLoaded(List.from(_orders)));

        _auditService.log(
          hotelId: hotelId,
          performedBy: userId,
          performedByRole: userRole,
          action: AuditAction.update,
          targetUserId: poId,
          description: 'Updated status of PO ${updatedPO.poNumber} to $status',
        );
      }
    } catch (e) {
      emit(PurchaseOrderError('Failed to update PO status: ${e.toString()}'));
    }
  }

  Future<void> cancelPOLineItem(
    String poId,
    String inventoryItemId, {
    required String userId,
    required String userName,
    required String userRole,
    required String hotelId,
  }) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index != -1) {
        final order = _orders[index];
        final lineItems = List<POLineItem>.from(order.lineItems);
        final itemIndex = lineItems.indexWhere(
          (li) => li.inventoryItemId == inventoryItemId,
        );

        if (itemIndex != -1) {
          final item = lineItems[itemIndex];
          lineItems[itemIndex] = item.copyWith(isCancelled: true);

          final updatedPO = order.copyWith(lineItems: lineItems);
          await _repository.savePurchaseOrder(updatedPO);
          _orders[index] = updatedPO;
          emit(PurchaseOrderLoaded(List.from(_orders)));

          _auditService.log(
            hotelId: hotelId,
            performedBy: userId,
            performedByRole: userRole,
            action: AuditAction.update,
            targetUserId: poId,
            description:
                'Cancelled item ${item.itemName} in PO ${updatedPO.poNumber}',
          );
        }
      }
    } catch (e) {
      emit(
        PurchaseOrderError('Failed to cancel PO line item: ${e.toString()}'),
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
