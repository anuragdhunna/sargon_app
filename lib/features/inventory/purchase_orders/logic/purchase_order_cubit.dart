import 'package:uuid/uuid.dart';

import '../../inventory_index.dart';

/// Cubit for managing purchase order operations
class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  PurchaseOrderCubit() : super(PurchaseOrderInitial()) {
    loadPurchaseOrders();
  }

  final _uuid = const Uuid();
  final List<PurchaseOrder> _mockOrders = [];

  void loadPurchaseOrders() async {
    emit(PurchaseOrderLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    // Initialize with mock data
    if (_mockOrders.isEmpty) {
      _initializeMockData();
    }

    emit(PurchaseOrderLoaded(List.from(_mockOrders)));
  }

  void _initializeMockData() {
    final now = DateTime.now();

    // Completed PO
    _mockOrders.add(
      PurchaseOrder(
        id: 'po_001',
        poNumber: 'PO-2025-001',
        vendorId: 'vendor_001',
        vendorName: 'Fresh Dairy Farms',
        lineItems: [
          POLineItem(
            id: 'poli_001',
            inventoryItemId: '1',
            itemName: 'Milk (Full Cream)',
            unit: UnitType.liters,
            orderedQuantity: 50,
            receivedQuantity: 50,
            pricePerUnit: 60.0,
          ),
          POLineItem(
            id: 'poli_002',
            inventoryItemId: '2',
            itemName: 'Paneer',
            unit: UnitType.kg,
            orderedQuantity: 10,
            receivedQuantity: 10,
            pricePerUnit: 350.0,
          ),
        ],
        status: POStatus.completed,
        createdAt: now.subtract(const Duration(days: 5)),
        createdBy: 'John Manager',
        expectedDeliveryDate: now.subtract(const Duration(days: 3)),
        shippingCost: 100.0,
        taxAmount: 450.0,
      ),
    );

    // Partial PO
    _mockOrders.add(
      PurchaseOrder(
        id: 'po_002',
        poNumber: 'PO-2025-002',
        vendorId: 'vendor_002',
        vendorName: 'Green Valley Vegetables',
        lineItems: [
          POLineItem(
            id: 'poli_003',
            inventoryItemId: '3',
            itemName: 'Tomatoes',
            unit: UnitType.kg,
            orderedQuantity: 30,
            receivedQuantity: 15,
            pricePerUnit: 40.0,
          ),
          POLineItem(
            id: 'poli_004',
            inventoryItemId: '4',
            itemName: 'Onions',
            unit: UnitType.kg,
            orderedQuantity: 25,
            receivedQuantity: 25,
            pricePerUnit: 35.0,
          ),
          POLineItem(
            id: 'poli_005',
            inventoryItemId: '5',
            itemName: 'Potatoes',
            unit: UnitType.kg,
            orderedQuantity: 40,
            receivedQuantity: 0,
            pricePerUnit: 30.0,
          ),
        ],
        status: POStatus.partial,
        createdAt: now.subtract(const Duration(days: 2)),
        createdBy: 'John Manager',
        expectedDeliveryDate: now.add(const Duration(days: 1)),
        notes: 'Partial delivery expected due to supply shortage',
      ),
    );

    // Pending PO
    _mockOrders.add(
      PurchaseOrder(
        id: 'po_003',
        poNumber: 'PO-2025-003',
        vendorId: 'vendor_003',
        vendorName: 'Premium Beverages Ltd',
        lineItems: [
          POLineItem(
            id: 'poli_006',
            inventoryItemId: '2',
            itemName: 'Vodka (Absolut)',
            unit: UnitType.bottles,
            orderedQuantity: 20,
            receivedQuantity: 0,
            pricePerUnit: 2500.0,
          ),
          POLineItem(
            id: 'poli_007',
            inventoryItemId: '6',
            itemName: 'Whiskey (JW Black)',
            unit: UnitType.bottles,
            orderedQuantity: 15,
            receivedQuantity: 0,
            pricePerUnit: 3200.0,
          ),
        ],
        status: POStatus.sent,
        createdAt: now.subtract(const Duration(days: 1)),
        createdBy: 'John Manager',
        expectedDeliveryDate: now.add(const Duration(days: 3)),
        shippingCost: 200.0,
        taxAmount: 12600.0,
      ),
    );
  }

  void createPurchaseOrder({
    required String vendorId,
    required String vendorName,
    required List<POLineItem> lineItems,
    required String createdBy,
    DateTime? expectedDeliveryDate,
    String? notes,
    double? shippingCost,
    double? taxAmount,
    required String userId,
    required String userName,
    required String userRole,
  }) {
    final poNumber = 'PO-${DateTime.now().year}-${_mockOrders.length + 1}'
        .padLeft(12, '0');
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

    _mockOrders.insert(0, po);
    emit(PurchaseOrderLoaded(List.from(_mockOrders)));

    AuditService().log(
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.createPO,
      entity: 'purchase_order',
      entityId: po.id,
      description:
          'Created PO ${po.poNumber} for vendor $vendorName with ${lineItems.length} items',
    );
  }

  void updatePOStatus(String poId, POStatus newStatus) {
    final index = _mockOrders.indexWhere((po) => po.id == poId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(status: newStatus);
      emit(PurchaseOrderLoaded(List.from(_mockOrders)));
    }
  }

  void updateLineItemReceived(
    String poId,
    String lineItemId,
    double receivedQuantity,
  ) {
    final index = _mockOrders.indexWhere((po) => po.id == poId);
    if (index != -1) {
      final po = _mockOrders[index];
      final updatedLineItems = po.lineItems.map((item) {
        if (item.id == lineItemId) {
          return item.copyWith(
            receivedQuantity: item.receivedQuantity + receivedQuantity,
          );
        }
        return item;
      }).toList();

      // Determine new PO status
      POStatus newStatus;
      if (updatedLineItems.every((item) => item.isFullyReceived)) {
        newStatus = POStatus.completed;
      } else if (updatedLineItems.any((item) => item.receivedQuantity > 0)) {
        newStatus = POStatus.partial;
      } else {
        newStatus = po.status;
      }

      _mockOrders[index] = po.copyWith(
        lineItems: updatedLineItems,
        status: newStatus,
      );
      emit(PurchaseOrderLoaded(List.from(_mockOrders)));
    }
  }

  void cancelPurchaseOrder(
    String poId, {
    required String userId,
    required String userName,
    required String userRole,
    String? reason,
  }) {
    final index = _mockOrders.indexWhere((po) => po.id == poId);
    if (index != -1) {
      final po = _mockOrders[index];
      _mockOrders[index] = po.copyWith(status: POStatus.cancelled);
      emit(PurchaseOrderLoaded(List.from(_mockOrders)));

      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.cancelPO,
        entity: 'purchase_order',
        entityId: poId,
        description:
            'Cancelled PO ${po.poNumber}${reason != null ? ': $reason' : ''}',
      );
    }
  }

  PurchaseOrder? getPOById(String id) {
    try {
      return _mockOrders.firstWhere((po) => po.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PurchaseOrder> getPOsByStatus(POStatus status) {
    return _mockOrders.where((po) => po.status == status).toList();
  }

  List<PurchaseOrder> getPendingAndPartialPOs() {
    return _mockOrders
        .where(
          (po) => po.status == POStatus.sent || po.status == POStatus.partial,
        )
        .toList();
  }
}
