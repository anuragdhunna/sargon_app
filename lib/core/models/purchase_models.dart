import 'package:equatable/equatable.dart';
import 'base_entity.dart';
import 'inventory_models.dart';

/// PO Status enum
enum POStatus { draft, pendingApproval, sent, partial, completed, cancelled }

/// Extension for POStatus
extension POStatusExtension on POStatus {
  String get displayName {
    switch (this) {
      case POStatus.draft:
        return 'Draft';
      case POStatus.pendingApproval:
        return 'Pending Approval';
      case POStatus.sent:
        return 'Sent';
      case POStatus.partial:
        return 'Partially Received';
      case POStatus.completed:
        return 'Completed';
      case POStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Purchase Order Line Item
class POLineItem extends Equatable {
  final String id;
  final String inventoryItemId;
  final String itemName;
  final UnitType unit;
  final double orderedQuantity;
  final double receivedQuantity;
  final double pricePerUnit;
  final String? notes;
  final bool isCancelled;

  const POLineItem({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.unit,
    required this.orderedQuantity,
    this.receivedQuantity = 0,
    required this.pricePerUnit,
    this.notes,
    this.isCancelled = false,
  });

  double get pendingQuantity => orderedQuantity - receivedQuantity;
  double get totalPrice => orderedQuantity * pricePerUnit;
  bool get isFullyReceived => receivedQuantity >= orderedQuantity;
  bool get isPartiallyReceived =>
      receivedQuantity > 0 && receivedQuantity < orderedQuantity;

  POLineItem copyWith({
    double? receivedQuantity,
    String? notes,
    bool? isCancelled,
  }) {
    return POLineItem(
      id: id,
      inventoryItemId: inventoryItemId,
      itemName: itemName,
      unit: unit,
      orderedQuantity: orderedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      pricePerUnit: pricePerUnit,
      notes: notes ?? this.notes,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    inventoryItemId,
    itemName,
    unit,
    orderedQuantity,
    receivedQuantity,
    pricePerUnit,
    notes,
    isCancelled,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'itemName': itemName,
      'unit': unit.name,
      'orderedQuantity': orderedQuantity,
      'receivedQuantity': receivedQuantity,
      'pricePerUnit': pricePerUnit,
      'notes': notes,
      'isCancelled': isCancelled,
    };
  }

  factory POLineItem.fromJson(Map<String, dynamic> json) {
    return POLineItem(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      itemName: json['itemName'] as String,
      unit: UnitType.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => UnitType.pieces,
      ),
      orderedQuantity: (json['orderedQuantity'] as num).toDouble(),
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      notes: json['notes'] as String?,
      isCancelled: json['isCancelled'] as bool? ?? false,
    );
  }
}

/// Purchase Order model
class PurchaseOrder extends BaseEntity {
  final String poNumber;
  final String? vendorId;
  final String? vendorName;
  final List<POLineItem> lineItems;
  final POStatus status;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final double? shippingCost;
  final double? taxAmount;

  const PurchaseOrder({
    required super.id,
    required super.hotelId,
    required this.poNumber,
    this.vendorId,
    this.vendorName,
    required this.lineItems,
    required this.status,
    this.expectedDeliveryDate,
    this.notes,
    this.shippingCost,
    this.taxAmount,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();

  double get subtotal =>
      lineItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal + (shippingCost ?? 0) + (taxAmount ?? 0);

  int get totalItemsOrdered => lineItems.length;
  int get itemsFullyReceived =>
      lineItems.where((item) => item.isFullyReceived).length;
  bool get isFullyReceived => itemsFullyReceived == totalItemsOrdered;

  @override
  List<Object?> get props => [
    ...super.props,
    poNumber,
    vendorId,
    vendorName,
    lineItems,
    status,
    expectedDeliveryDate,
    notes,
    shippingCost,
    taxAmount,
  ];

  PurchaseOrder copyWith({
    String? id,
    String? hotelId,
    POStatus? status,
    List<POLineItem>? lineItems,
    String? notes,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      poNumber: poNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      lineItems: lineItems ?? this.lineItems,
      status: status ?? this.status,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes ?? this.notes,
      shippingCost: shippingCost,
      taxAmount: taxAmount,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'poNumber': poNumber,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'status': status.name,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'notes': notes,
      'shippingCost': shippingCost,
      'taxAmount': taxAmount,
    };
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      poNumber: json['poNumber'] as String,
      vendorId: json['vendorId'] as String?,
      vendorName: json['vendorName'] as String?,
      lineItems:
          (json['lineItems'] as List?)
              ?.map((item) => POLineItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: POStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => POStatus.draft,
      ),
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['createdAt'],
      ),
      expectedDeliveryDate: BaseEntity.parseDateTime(
        json['expectedDeliveryDate'],
      ),
      notes: json['notes'] as String?,
      shippingCost: (json['shippingCost'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

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
class GoodsReceiptNote extends BaseEntity {
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

  const GoodsReceiptNote({
    required super.id,
    required super.hotelId,
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
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  double get totalValue =>
      lineItems.fold(0, (sum, item) => sum + item.totalValue);

  bool get isLinkedToPO => purchaseOrderId != null;
  int get totalItems => lineItems.length;
  bool get hasProofImages => billImagePath != null || goodsImagePath != null;

  @override
  List<Object?> get props => [
    ...super.props,
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

  GoodsReceiptNote copyWith({
    String? id,
    String? hotelId,
    List<GRNLineItem>? lineItems,
    String? notes,
  }) {
    return GoodsReceiptNote(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
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
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
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
    };
  }

  factory GoodsReceiptNote.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptNote(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
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
      receivedAt:
          BaseEntity.parseDateTime(json['receivedAt']) ?? DateTime.now(),
      receivedBy: json['receivedBy'] as String? ?? 'system',
      receivedByName: json['receivedByName'] as String? ?? 'System',
      deliveryPersonName: json['deliveryPersonName'] as String?,
      deliveryPersonPhone: json['deliveryPersonPhone'] as String?,
      billImagePath: json['billImagePath'] as String?,
      goodsImagePath: json['goodsImagePath'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
