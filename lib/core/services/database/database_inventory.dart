part of '../database_service.dart';

extension DatabaseInventory on DatabaseService {
  CollectionReference _inventoryRef(String hotelId) =>
      _hotelDoc(hotelId).collection('inventory');
  CollectionReference _vendorsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('vendors');
  CollectionReference _purchaseOrdersRef(String hotelId) =>
      _hotelDoc(hotelId).collection('purchaseOrders');
  CollectionReference _goodsReceiptsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('goodsReceipts');

  /// Stream all inventory items (real-time)
  Stream<List<InventoryItem>> streamInventory(String hotelId) {
    return _inventoryRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return InventoryItem.fromJson(data);
      }).toList();
    });
  }

  /// Get inventory items (one-time fetch)
  Future<List<InventoryItem>> getInventory(String hotelId) async {
    final snapshot = await _inventoryRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return InventoryItem.fromJson(data);
    }).toList();
  }

  /// Stream low stock items
  Stream<List<InventoryItem>> streamLowStockItems(String hotelId) {
    return streamInventory(
      hotelId,
    ).map((items) => items.where((item) => item.isLowStock).toList());
  }

  /// Save inventory item
  Future<void> saveInventoryItem(InventoryItem item) async {
    await _inventoryRef(item.hotelId).doc(item.id).set(item.toJson());
  }

  /// Update inventory quantity
  Future<void> updateInventoryQuantity(
    String hotelId,
    String itemId,
    double quantity,
  ) async {
    await _inventoryRef(hotelId).doc(itemId).update({
      'quantity': quantity,
      'lastRestockedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream all vendors (real-time)
  Stream<List<Vendor>> streamVendors(String hotelId) {
    return _vendorsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Vendor.fromJson(data);
      }).toList();
    });
  }

  /// Get all vendors once
  Future<List<Vendor>> getVendors(String hotelId) async {
    final snapshot = await _vendorsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Vendor.fromJson(data);
    }).toList();
  }

  /// Save vendor
  Future<void> saveVendor(Vendor vendor) async {
    await _vendorsRef(vendor.hotelId).doc(vendor.id).set(vendor.toJson());
  }

  /// Stream all purchase orders (real-time)
  Stream<List<PurchaseOrder>> streamPurchaseOrders(String hotelId) {
    return _purchaseOrdersRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PurchaseOrder.fromJson(data);
      }).toList();
    });
  }

  /// Get all purchase orders once
  Future<List<PurchaseOrder>> getPurchaseOrders(String hotelId) async {
    final snapshot = await _purchaseOrdersRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PurchaseOrder.fromJson(data);
    }).toList();
  }

  /// Save purchase order
  Future<void> savePurchaseOrder(PurchaseOrder po) async {
    await _purchaseOrdersRef(po.hotelId).doc(po.id).set(po.toJson());
  }

  /// Stream all goods receipts (real-time)
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts(String hotelId) {
    return _goodsReceiptsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoodsReceiptNote.fromJson(data);
      }).toList();
    });
  }

  /// Get all goods receipts once
  Future<List<GoodsReceiptNote>> getGoodsReceipts(String hotelId) async {
    final snapshot = await _goodsReceiptsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GoodsReceiptNote.fromJson(data);
    }).toList();
  }

  /// Save goods receipt
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn) async {
    await _goodsReceiptsRef(grn.hotelId).doc(grn.id).set(grn.toJson());
  }

  /// Deduct stock for an item
  Future<void> deductStock(
    String hotelId,
    String itemId,
    double quantity,
  ) async {
    final doc = await _inventoryRef(hotelId).doc(itemId).get();
    if (doc.exists) {
      final current = InventoryItem.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      final newQty = current.quantity - quantity;
      await updateInventoryQuantity(hotelId, itemId, newQty);
    }
  }

  /// Add stock for an item
  Future<void> addStock(String hotelId, String itemId, double quantity) async {
    final doc = await _inventoryRef(hotelId).doc(itemId).get();
    if (doc.exists) {
      final current = InventoryItem.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      final newQty = current.quantity + quantity;
      await updateInventoryQuantity(hotelId, itemId, newQty);
    }
  }
}
