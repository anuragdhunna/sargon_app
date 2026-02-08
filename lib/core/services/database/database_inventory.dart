part of '../database_service.dart';

extension DatabaseInventory on DatabaseService {
  DatabaseReference get inventoryRef => _ref('inventory');
  DatabaseReference get vendorsRef => _ref('vendors');
  DatabaseReference get purchaseOrdersRef => _ref('purchaseOrders');
  DatabaseReference get goodsReceiptsRef => _ref('goodsReceipts');

  /// Stream all inventory items (real-time)
  Stream<List<InventoryItem>> streamInventory() {
    return inventoryRef.onValue.map((event) {
      if (event.snapshot.value == null) return <InventoryItem>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <InventoryItem>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final itemData = _toMap(e.value);
        return InventoryItem.fromJson(itemData);
      }).toList();
    });
  }

  /// Stream low stock items
  Stream<List<InventoryItem>> streamLowStockItems() {
    return streamInventory().map(
      (items) => items.where((item) => item.isLowStock).toList(),
    );
  }

  /// Save inventory item
  Future<void> saveInventoryItem(InventoryItem item) async {
    await inventoryRef.child(item.id).set(item.toJson());
  }

  /// Update inventory quantity
  Future<void> updateInventoryQuantity(String itemId, double quantity) async {
    await inventoryRef.child(itemId).update({
      'quantity': quantity,
      'lastRestockedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream all vendors (real-time)
  Stream<List<Vendor>> streamVendors() {
    return vendorsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <Vendor>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <Vendor>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final vendorData = _toMap(e.value);
        return Vendor.fromJson(vendorData);
      }).toList();
    });
  }

  /// Get all vendors once
  Future<List<Vendor>> getVendors() async {
    final snapshot = await vendorsRef.get();
    if (snapshot.value == null) return <Vendor>[];
    final dynamic value = snapshot.value;
    final Map<dynamic, dynamic> data = (value is Map)
        ? value
        : (value is List ? value.asMap() : {});

    return data.entries.map((e) {
      final vendorData = _toMap(e.value);
      return Vendor.fromJson(vendorData);
    }).toList();
  }

  /// Save vendor
  Future<void> saveVendor(Vendor vendor) async {
    await vendorsRef.child(vendor.id).set(vendor.toJson());
  }

  /// Stream all purchase orders (real-time)
  Stream<List<PurchaseOrder>> streamPurchaseOrders() {
    return purchaseOrdersRef.onValue.map((event) {
      if (event.snapshot.value == null) return <PurchaseOrder>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <PurchaseOrder>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final poData = _toMap(e.value);
        return PurchaseOrder.fromJson(poData);
      }).toList();
    });
  }

  /// Get all purchase orders once
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final snapshot = await purchaseOrdersRef.get();
    if (snapshot.value == null) return <PurchaseOrder>[];
    final dynamic value = snapshot.value;
    final Map<dynamic, dynamic> data = (value is Map)
        ? value
        : (value is List ? value.asMap() : {});

    return data.entries.map((e) {
      final poData = _toMap(e.value);
      return PurchaseOrder.fromJson(poData);
    }).toList();
  }

  /// Save purchase order
  Future<void> savePurchaseOrder(PurchaseOrder po) async {
    await purchaseOrdersRef.child(po.id).set(po.toJson());
  }

  /// Stream all goods receipts (real-time)
  Stream<List<GoodsReceiptNote>> streamGoodsReceipts() {
    return goodsReceiptsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <GoodsReceiptNote>[];
      final dynamic value = event.snapshot.value;
      final data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final grnData = _toMap(e.value);
        return GoodsReceiptNote.fromJson(grnData);
      }).toList();
    });
  }

  /// Get all goods receipts once
  Future<List<GoodsReceiptNote>> getGoodsReceipts() async {
    final snapshot = await goodsReceiptsRef.get();
    if (snapshot.value == null) return <GoodsReceiptNote>[];
    final dynamic value = snapshot.value;
    final data = (value is Map) ? value : (value is List ? value.asMap() : {});

    return data.entries.map((e) {
      final grnData = _toMap(e.value);
      return GoodsReceiptNote.fromJson(grnData);
    }).toList();
  }

  /// Save goods receipt
  Future<void> saveGoodsReceipt(GoodsReceiptNote grn) async {
    await goodsReceiptsRef.child(grn.id).set(grn.toJson());
  }

  /// Deduct stock for an item
  Future<void> deductStock(String itemId, double quantity) async {
    final snapshot = await inventoryRef.child(itemId).get();
    if (snapshot.value != null) {
      final current = InventoryItem.fromJson(_toMap(snapshot.value));
      final newQty = current.quantity - quantity;
      await updateInventoryQuantity(itemId, newQty);
    }
  }

  /// Add stock for an item
  Future<void> addStock(String itemId, double quantity) async {
    final snapshot = await inventoryRef.child(itemId).get();
    if (snapshot.value != null) {
      final current = InventoryItem.fromJson(_toMap(snapshot.value));
      final newQty = current.quantity + quantity;
      await updateInventoryQuantity(itemId, newQty);
    }
  }
}
