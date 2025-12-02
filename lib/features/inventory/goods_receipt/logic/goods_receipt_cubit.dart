import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/data/goods_receipt_model.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_state.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
import 'package:hotel_manager/features/inventory/purchase_orders/logic/purchase_order_cubit.dart';
import 'package:uuid/uuid.dart';

/// Cubit for managing goods receipt operations
class GoodsReceiptCubit extends Cubit<GoodsReceiptState> {
  final InventoryCubit inventoryCubit;
  final PurchaseOrderCubit purchaseOrderCubit;

  GoodsReceiptCubit({
    required this.inventoryCubit,
    required this.purchaseOrderCubit,
  }) : super(GoodsReceiptInitial()) {
    loadGoodsReceipts();
  }

  final _uuid = const Uuid();
  final List<GoodsReceiptNote> _mockGRNs = [];

  void loadGoodsReceipts() async {
    emit(GoodsReceiptLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    // Initialize with mock data
    if (_mockGRNs.isEmpty) {
      _initializeMockData();
    }

    emit(GoodsReceiptLoaded(List.from(_mockGRNs)));
  }

  void _initializeMockData() {
    final now = DateTime.now();

    // GRN for completed PO
    _mockGRNs.add(
      GoodsReceiptNote(
        id: 'grn_001',
        grnNumber: 'GRN-2025-001',
        purchaseOrderId: 'po_001',
        purchaseOrderNumber: 'PO-2025-001',
        vendorId: 'vendor_001',
        vendorName: 'Fresh Dairy Farms',
        lineItems: [
          GRNLineItem(
            id: 'grnli_001',
            inventoryItemId: '1',
            itemName: 'Milk (Full Cream)',
            unit: UnitType.liters,
            quantityReceived: 50,
            pricePerUnit: 60.0,
            qualityCheckPassed: true,
          ),
          GRNLineItem(
            id: 'grnli_002',
            inventoryItemId: '2',
            itemName: 'Paneer',
            unit: UnitType.kg,
            quantityReceived: 10,
            pricePerUnit: 350.0,
            qualityCheckPassed: true,
          ),
        ],
        receivedAt: now.subtract(const Duration(days: 3)),
        receivedBy: 'user_123',
        receivedByName: 'John Manager',
        deliveryPersonName: 'Rajesh Kumar',
        deliveryPersonPhone: '+91 9876543210',
        billImagePath: '/mock/images/bill_001.jpg',
        goodsImagePath: '/mock/images/goods_001.jpg',
        invoiceNumber: 'INV-DF-2025-001',
        notes: 'All items in good condition',
      ),
    );

    // Partial GRN
    _mockGRNs.add(
      GoodsReceiptNote(
        id: 'grn_002',
        grnNumber: 'GRN-2025-002',
        purchaseOrderId: 'po_002',
        purchaseOrderNumber: 'PO-2025-002',
        vendorId: 'vendor_002',
        vendorName: 'Green Valley Vegetables',
        lineItems: [
          GRNLineItem(
            id: 'grnli_003',
            inventoryItemId: '3',
            itemName: 'Tomatoes',
            unit: UnitType.kg,
            quantityReceived: 15,
            pricePerUnit: 40.0,
            qualityCheckPassed: true,
            notes: 'Partial delivery - rest coming tomorrow',
          ),
          GRNLineItem(
            id: 'grnli_004',
            inventoryItemId: '4',
            itemName: 'Onions',
            unit: UnitType.kg,
            quantityReceived: 25,
            pricePerUnit: 35.0,
            qualityCheckPassed: true,
          ),
        ],
        receivedAt: now.subtract(const Duration(hours: 6)),
        receivedBy: 'user_456',
        receivedByName: 'Sarah Chef',
        deliveryPersonName: 'Amit Singh',
        deliveryPersonPhone: '+91 9876543211',
        billImagePath: '/mock/images/bill_002.jpg',
        invoiceNumber: 'INV-GV-2025-045',
        notes: 'Partial delivery - potatoes pending',
      ),
    );
  }

  Future<void> createGoodsReceipt({
    String? purchaseOrderId,
    String? vendorId,
    String? vendorName,
    required List<GRNLineItem> lineItems,
    required String receivedBy,
    required String receivedByName,
    String? deliveryPersonName,
    String? deliveryPersonPhone,
    String? billImagePath,
    String? goodsImagePath,
    String? invoiceNumber,
    String? notes,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      emit(GoodsReceiptLoading());

      final grnNumber = 'GRN-${DateTime.now().year}-${_mockGRNs.length + 1}'
          .padLeft(12, '0');
      String? poNumber;

      // Get PO details if linked
      if (purchaseOrderId != null) {
        final po = purchaseOrderCubit.getPOById(purchaseOrderId);
        if (po == null) {
          emit(const GoodsReceiptError('Purchase Order not found'));
          return;
        }
        poNumber = po.poNumber;
        vendorId ??= po.vendorId;
        vendorName ??= po.vendorName;

        // Update PO line items with received quantities
        for (var grnItem in lineItems) {
          purchaseOrderCubit.updateLineItemReceived(
            purchaseOrderId,
            grnItem.inventoryItemId,
            grnItem.quantityReceived,
          );
        }
      }

      final grn = GoodsReceiptNote(
        id: _uuid.v4(),
        grnNumber: grnNumber,
        purchaseOrderId: purchaseOrderId,
        purchaseOrderNumber: poNumber,
        vendorId: vendorId,
        vendorName: vendorName,
        lineItems: lineItems,
        receivedAt: DateTime.now(),
        receivedBy: receivedBy,
        receivedByName: receivedByName,
        deliveryPersonName: deliveryPersonName,
        deliveryPersonPhone: deliveryPersonPhone,
        billImagePath: billImagePath,
        goodsImagePath: goodsImagePath,
        invoiceNumber: invoiceNumber,
        notes: notes,
      );

      _mockGRNs.insert(0, grn);

      // Update inventory for each line item
      for (var item in lineItems) {
        inventoryCubit.receiveStock(
          inventoryItemId: item.inventoryItemId,
          quantity: item.quantityReceived,
          grnNumber: grnNumber,
          userId: userId,
          userName: userName,
          userRole: userRole,
        );
      }

      // Log the receiving action
      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.receive,
        entity: 'goods_receipt',
        entityId: grn.id,
        description:
            'Received ${lineItems.length} items via $grnNumber${purchaseOrderId != null ? ' against $poNumber' : ' (without PO)'}',
        metadata: {
          'grnNumber': grnNumber,
          'poNumber': poNumber,
          'vendorName': vendorName,
          'totalValue': grn.totalValue,
        },
      );

      emit(GoodsReceiptLoaded(List.from(_mockGRNs)));
    } catch (e) {
      emit(GoodsReceiptError('Failed to create GRN: ${e.toString()}'));
    }
  }

  GoodsReceiptNote? getGRNById(String id) {
    try {
      return _mockGRNs.firstWhere((grn) => grn.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GoodsReceiptNote> getGRNsByPO(String poId) {
    return _mockGRNs.where((grn) => grn.purchaseOrderId == poId).toList();
  }

  List<GoodsReceiptNote> getGRNsByVendor(String vendorId) {
    return _mockGRNs.where((grn) => grn.vendorId == vendorId).toList();
  }

  List<GoodsReceiptNote> getGRNsByDateRange(DateTime start, DateTime end) {
    return _mockGRNs
        .where(
          (grn) =>
              grn.receivedAt.isAfter(start) && grn.receivedAt.isBefore(end),
        )
        .toList();
  }
}
