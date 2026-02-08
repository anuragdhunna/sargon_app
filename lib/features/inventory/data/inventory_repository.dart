import '../../../core/services/database_service.dart';
import '../vendors/data/vendor_model.dart';
import '../purchase_orders/data/purchase_order_model.dart';
import '../goods_receipt/data/goods_receipt_model.dart';
import '../stock/data/inventory_model.dart';

abstract class IInventoryRepository {
  Future<List<Vendor>> getVendors();
  Future<void> saveVendor(Vendor vendor);
  Stream<List<Vendor>> streamVendors();

  Future<List<PurchaseOrder>> getPurchaseOrders();
  Future<void> savePurchaseOrder(PurchaseOrder po);
  Stream<List<PurchaseOrder>> streamPurchaseOrders();

  Future<List<GoodsReceiptNote>> getGoodsReceipts();
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn);
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts();

  Stream<List<InventoryItem>> streamInventory();
  Future<void> saveInventoryItem(InventoryItem item);
  Future<void> updateInventoryQuantity(String itemId, double quantity);
  Future<void> addStock(String itemId, double quantity);
  Future<void> deductStock(String itemId, double quantity);
}

class InventoryRepository implements IInventoryRepository {
  final DatabaseService _databaseService;

  InventoryRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<List<Vendor>> getVendors() => _databaseService.getVendors();

  @override
  Future<void> saveVendor(Vendor vendor) => _databaseService.saveVendor(vendor);

  @override
  Stream<List<Vendor>> streamVendors() => _databaseService.streamVendors();

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() =>
      _databaseService.getPurchaseOrders();

  @override
  Future<void> savePurchaseOrder(PurchaseOrder po) =>
      _databaseService.savePurchaseOrder(po);

  @override
  Stream<List<PurchaseOrder>> streamPurchaseOrders() =>
      _databaseService.streamPurchaseOrders();

  @override
  Future<List<GoodsReceiptNote>> getGoodsReceipts() =>
      _databaseService.getGoodsReceipts();

  @override
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn) =>
      _databaseService.saveGoodsReceipt(grn);

  @override
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts() =>
      _databaseService.streamGoodsReceipts();

  @override
  Stream<List<InventoryItem>> streamInventory() =>
      _databaseService.streamInventory();

  @override
  Future<void> saveInventoryItem(InventoryItem item) =>
      _databaseService.saveInventoryItem(item);

  @override
  Future<void> updateInventoryQuantity(String itemId, double quantity) =>
      _databaseService.updateInventoryQuantity(itemId, quantity);

  @override
  Future<void> addStock(String itemId, double quantity) =>
      _databaseService.addStock(itemId, quantity);

  @override
  Future<void> deductStock(String itemId, double quantity) =>
      _databaseService.deductStock(itemId, quantity);
}
