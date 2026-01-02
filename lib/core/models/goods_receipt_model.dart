import 'package:equatable/equatable.dart';
import 'inventory_item_model.dart';

/// Goods Receipt Note Line Item
class GRNLineItem extends Equatable {
  final String id;
  final String inventoryItemId;
  final String itemName;
  final UnitType unit;
  final double quantityReceived;
  final double pricePerUnit;
  final bool qualityCheckPassed;
  final String? notes;

  const GRNLineItem({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.unit,
    required this.quantityReceived,
    required this.pricePerUnit,
    this.qualityCheckPassed = true,
    this.notes,
  });

  double get totalValue => quantityReceived * pricePerUnit;

  @override
  List<Object?> get props => [
    id,
    inventoryItemId,
    itemName,
    unit,
    quantityReceived,
    pricePerUnit,
    qualityCheckPassed,
    notes,
  ];

  GRNLineItem copyWith({
    double? quantityReceived,
    bool? qualityCheckPassed,
    String? notes,
  }) {
    return GRNLineItem(
      id: id,
      inventoryItemId: inventoryItemId,
      itemName: itemName,
      unit: unit,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      pricePerUnit: pricePerUnit,
      qualityCheckPassed: qualityCheckPassed ?? this.qualityCheckPassed,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'itemName': itemName,
      'unit': unit.name,
      'quantityReceived': quantityReceived,
      'pricePerUnit': pricePerUnit,
      'qualityCheckPassed': qualityCheckPassed,
      'notes': notes,
    };
  }

  factory GRNLineItem.fromJson(Map<String, dynamic> json) {
    return GRNLineItem(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      itemName: json['itemName'] as String,
      unit: UnitType.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => UnitType.pieces,
      ),
      quantityReceived: (json['quantityReceived'] as num).toDouble(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      qualityCheckPassed: json['qualityCheckPassed'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}

/// Goods Receipt Note model
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class GoodsReceiptNote extends Equatable {
  final String id;
  final String grnNumber;
  final String? purchaseOrderId;
  final String? purchaseOrderNumber;
  final String? vendorId;
  final String? vendorName;
  final List<GRNLineItem> lineItems;
  final DateTime receivedAt;
  final String receivedBy;
  final String receivedByName;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? billImagePath;
  final String? goodsImagePath;
  final String? invoiceNumber;
  final String? notes;

  // Schema version for migrations
  static const int schemaVersion = 1;

  const GoodsReceiptNote({
    required this.id,
    required this.grnNumber,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    this.vendorId,
    this.vendorName,
    required this.lineItems,
    required this.receivedAt,
    required this.receivedBy,
    required this.receivedByName,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.billImagePath,
    this.goodsImagePath,
    this.invoiceNumber,
    this.notes,
  });

  double get totalValue =>
      lineItems.fold(0, (sum, item) => sum + item.totalValue);
  int get totalItems => lineItems.length;
  bool get hasProofImages => billImagePath != null || goodsImagePath != null;
  bool get isLinkedToPO => purchaseOrderId != null;

  @override
  List<Object?> get props => [
    id,
    grnNumber,
    purchaseOrderId,
    purchaseOrderNumber,
    vendorId,
    vendorName,
    lineItems,
    receivedAt,
    receivedBy,
    receivedByName,
    deliveryPersonName,
    deliveryPersonPhone,
    billImagePath,
    goodsImagePath,
    invoiceNumber,
    notes,
  ];

  GoodsReceiptNote copyWith({List<GRNLineItem>? lineItems, String? notes}) {
    return GoodsReceiptNote(
      id: id,
      grnNumber: grnNumber,
      purchaseOrderId: purchaseOrderId,
      purchaseOrderNumber: purchaseOrderNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      lineItems: lineItems ?? this.lineItems,
      receivedAt: receivedAt,
      receivedBy: receivedBy,
      receivedByName: receivedByName,
      deliveryPersonName: deliveryPersonName,
      deliveryPersonPhone: deliveryPersonPhone,
      billImagePath: billImagePath,
      goodsImagePath: goodsImagePath,
      invoiceNumber: invoiceNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grnNumber': grnNumber,
      'purchaseOrderId': purchaseOrderId,
      'purchaseOrderNumber': purchaseOrderNumber,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'receivedAt': receivedAt.toIso8601String(),
      'receivedBy': receivedBy,
      'receivedByName': receivedByName,
      'deliveryPersonName': deliveryPersonName,
      'deliveryPersonPhone': deliveryPersonPhone,
      'billImagePath': billImagePath,
      'goodsImagePath': goodsImagePath,
      'invoiceNumber': invoiceNumber,
      'notes': notes,
      '_schemaVersion': schemaVersion,
    };
  }

  factory GoodsReceiptNote.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptNote(
      id: json['id'] as String,
      grnNumber: json['grnNumber'] as String,
      purchaseOrderId: json['purchaseOrderId'] as String?,
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      vendorId: json['vendorId'] as String?,
      vendorName: json['vendorName'] as String?,
      lineItems:
          (json['lineItems'] as List?)
              ?.map(
                (item) => GRNLineItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      receivedBy: json['receivedBy'] as String,
      receivedByName: json['receivedByName'] as String,
      deliveryPersonName: json['deliveryPersonName'] as String?,
      deliveryPersonPhone: json['deliveryPersonPhone'] as String?,
      billImagePath: json['billImagePath'] as String?,
      goodsImagePath: json['goodsImagePath'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
