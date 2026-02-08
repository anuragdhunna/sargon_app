import 'package:uuid/uuid.dart';
import '../../inventory_index.dart';

/// Cubit for managing goods receipt notes
class GoodsReceiptCubit extends Cubit<GoodsReceiptState> {
  final InventoryCubit inventoryCubit;
  final PurchaseOrderCubit purchaseOrderCubit;
  final IInventoryRepository _repository;
  final AuditService _auditService;

  GoodsReceiptCubit({
    required this.inventoryCubit,
    required this.purchaseOrderCubit,
    IInventoryRepository? repository,
    AuditService? auditService,
  }) : _repository = repository ?? InventoryRepository(),
       _auditService = auditService ?? AuditService(),
       super(GoodsReceiptInitial()) {
    loadGoodsReceipts();
  }

  final _uuid = const Uuid();
  final List<GoodsReceiptNote> _receipts = [];

  Future<void> loadGoodsReceipts() async {
    emit(GoodsReceiptLoading());
    try {
      final receipts = await _repository.getGoodsReceipts();
      _receipts.clear();
      _receipts.addAll(receipts);
      emit(GoodsReceiptLoaded(List.from(_receipts)));
    } catch (e) {
      emit(GoodsReceiptError('Failed to load goods receipts: ${e.toString()}'));
    }
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
      String? poNumber;
      if (purchaseOrderId != null) {
        final po = purchaseOrderCubit.getPOById(purchaseOrderId);
        poNumber = po?.poNumber;
      }

      final grnNumber = 'GRN-${DateTime.now().year}-${_receipts.length + 1}'
          .padLeft(13, '0');

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

      await _repository.saveGoodsReceipt(grn);
      _receipts.insert(0, grn);
      emit(GoodsReceiptLoaded(List.from(_receipts)));

      // Update inventory stock
      for (var item in lineItems) {
        await inventoryCubit.receiveStock(
          inventoryItemId: item.inventoryItemId,
          quantity: item.quantityReceived,
          grnNumber: grn.grnNumber,
          userId: userId,
          userName: userName,
          userRole: userRole,
        );
      }

      // Update PO line item received quantity
      if (purchaseOrderId != null) {
        for (var item in lineItems) {
          await purchaseOrderCubit.updateLineItemReceived(
            purchaseOrderId,
            item.inventoryItemId,
            item.quantityReceived,
          );
        }
      }

      _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.receive,
        entity: 'goods_receipt',
        entityId: grn.id,
        description:
            'Received goods ${grn.grnNumber} ${poNumber != null ? '(against $poNumber)' : ''} from ${vendorName ?? 'Unknown Vendor'} with ${lineItems.length} items',
      );
    } catch (e) {
      emit(
        GoodsReceiptError('Failed to create goods receipt: ${e.toString()}'),
      );
    }
  }

  GoodsReceiptNote? getGRNById(String id) {
    try {
      return _receipts.firstWhere((grn) => grn.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GoodsReceiptNote> getGRNsByPO(String poId) {
    return _receipts.where((grn) => grn.purchaseOrderId == poId).toList();
  }

  List<GoodsReceiptNote> getGRNsByVendor(String vendorId) {
    return _receipts.where((grn) => grn.vendorId == vendorId).toList();
  }
}
