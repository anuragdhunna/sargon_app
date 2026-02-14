import 'package:equatable/equatable.dart';
import 'base_entity.dart';
import 'inventory_item_model.dart';

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
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
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

  // Schema version for migrations
  static const int schemaVersion = 1;

  const PurchaseOrder({
    required String id,
    required this.poNumber,
    this.vendorId,
    this.vendorName,
    required this.lineItems,
    required this.status,
    DateTime? createdAt,
    DateTime? createdOn,
    String? createdBy,
    this.expectedDeliveryDate,
    this.notes,
    this.shippingCost,
    this.taxAmount,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : super(
         id: id,
         createdOn: createdOn ?? createdAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

  /// Getters for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();
  String get createdBy => super.createdBy ?? 'system';

  double get subtotal =>
      lineItems.fold(0, (sum, item) => sum + item.totalPrice);

  double get total => subtotal + (shippingCost ?? 0) + (taxAmount ?? 0);

  bool get isFullyReceived => lineItems.every((item) => item.isFullyReceived);
  bool get hasPartialReceipts =>
      lineItems.any((item) => item.isPartiallyReceived);

  int get totalItemsOrdered => lineItems.length;
  int get itemsFullyReceived =>
      lineItems.where((item) => item.isFullyReceived).length;
  int get itemsPartiallyReceived =>
      lineItems.where((item) => item.isPartiallyReceived).length;

  PurchaseOrder copyWith({
    String? id,
    POStatus? status,
    List<POLineItem>? lineItems,
    String? notes,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool? isDeleted,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber,
      vendorId: vendorId,
      vendorName: vendorName,
      lineItems: lineItems ?? this.lineItems,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes ?? this.notes,
      shippingCost: shippingCost,
      taxAmount: taxAmount,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedOn: updatedOn ?? this.updatedOn,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

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
      '_schemaVersion': schemaVersion,
    };
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
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
      createdBy: json['createdBy'] as String? ?? 'system',
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
