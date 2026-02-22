import '../../../core/models/models.dart';
import '../../../core/services/database_service.dart';

abstract class IInventoryRepository {
  Future<List<Vendor>> getVendors(String hotelId);
  Future<void> saveVendor(Vendor vendor);
  Stream<List<Vendor>> streamVendors(String hotelId);

  Future<List<PurchaseOrder>> getPurchaseOrders(String hotelId);
  Future<void> savePurchaseOrder(PurchaseOrder po);
  Stream<List<PurchaseOrder>> streamPurchaseOrders(String hotelId);

  Future<List<GoodsReceiptNote>> getGoodsReceipts(String hotelId);
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn);
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts(String hotelId);

  Stream<List<InventoryItem>> streamInventory(String hotelId);
  Future<void> saveInventoryItem(InventoryItem item);
  Future<void> updateInventoryQuantity(
    String hotelId,
    String itemId,
    double quantity,
  );
  Future<void> addStock(String hotelId, String itemId, double quantity);
  Future<void> deductStock(String hotelId, String itemId, double quantity);
  Future<AppSettings> getAppSettings(String hotelId);
}

class InventoryRepository implements IInventoryRepository {
  final DatabaseService _databaseService;

  InventoryRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<List<Vendor>> getVendors(String hotelId) =>
      _databaseService.getVendors(hotelId);

  @override
  Future<void> saveVendor(Vendor vendor) => _databaseService.saveVendor(vendor);

  @override
  Stream<List<Vendor>> streamVendors(String hotelId) =>
      _databaseService.streamVendors(hotelId);

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders(String hotelId) =>
      _databaseService.getPurchaseOrders(hotelId);

  @override
  Future<void> savePurchaseOrder(PurchaseOrder po) =>
      _databaseService.savePurchaseOrder(po);

  @override
  Stream<List<PurchaseOrder>> streamPurchaseOrders(String hotelId) =>
      _databaseService.streamPurchaseOrders(hotelId);

  @override
  Future<List<GoodsReceiptNote>> getGoodsReceipts(String hotelId) =>
      _databaseService.getGoodsReceipts(hotelId);

  @override
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn) =>
      _databaseService.saveGoodsReceipt(grn);

  @override
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts(String hotelId) =>
      _databaseService.streamGoodsReceipts(hotelId);

  @override
  Stream<List<InventoryItem>> streamInventory(String hotelId) =>
      _databaseService.streamInventory(hotelId);

  @override
  Future<void> saveInventoryItem(InventoryItem item) =>
      _databaseService.saveInventoryItem(item);

  @override
  Future<void> updateInventoryQuantity(
    String hotelId,
    String itemId,
    double quantity,
  ) => _databaseService.updateInventoryQuantity(hotelId, itemId, quantity);

  @override
  Future<void> addStock(String hotelId, String itemId, double quantity) =>
      _databaseService.addStock(hotelId, itemId, quantity);

  @override
  Future<void> deductStock(String hotelId, String itemId, double quantity) =>
      _databaseService.deductStock(hotelId, itemId, quantity);

  @override
  Future<AppSettings> getAppSettings(String hotelId) =>
      _databaseService.getAppSettings(hotelId);
}
