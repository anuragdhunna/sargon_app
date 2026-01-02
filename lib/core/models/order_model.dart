import 'package:equatable/equatable.dart';
import 'menu_item_model.dart';
import 'payment_models.dart';

/// Overall Order status enum
enum OrderStatus { pending, cooking, ready, served, cancelled }

/// Extension for OrderStatus display names
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cooking:
        return 'Cooking';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Course type for items
enum CourseType { starters, mains, desserts, drinks }

/// KDS specific status for individual items
enum KdsStatus {
  pending, // Added but not fired
  fired, // Sent to kitchen
  preparing,
  ready,
  served,
  cancelled,
  delayed,
}

/// Order priority levels
enum OrderPriority { normal, vip, rush }

/// Order model representing a customer order with Table & KDS Intelligence
class Order extends Equatable {
  final String id;
  final String tableId;
  final String tableNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final DateTime? openedAt;
  final int paxCount;
  final OrderPriority priority;
  final String? orderNotes;
  final String? createdBy;
  final String? waiterName;
  final String? bookingId;
  final String? roomId;
  final String? guestName;
  final PaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;

  const Order({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.items,
    this.status = OrderStatus.pending,
    required this.timestamp,
    this.updatedAt,
    this.openedAt,
    this.paxCount = 1,
    this.priority = OrderPriority.normal,
    this.orderNotes,
    this.createdBy,
    this.waiterName,
    this.bookingId,
    this.roomId,
    this.guestName,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
  });

  @override
  List<Object?> get props => [
    id,
    tableId,
    tableNumber,
    items,
    status,
    timestamp,
    updatedAt,
    openedAt,
    paxCount,
    priority,
    orderNotes,
    createdBy,
    waiterName,
    bookingId,
    roomId,
    guestName,
    paymentMethod,
    paymentStatus,
  ];

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Order copyWith({
    String? id,
    String? tableId,
    String? tableNumber,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? timestamp,
    DateTime? updatedAt,
    DateTime? openedAt,
    int? paxCount,
    OrderPriority? priority,
    String? orderNotes,
    String? createdBy,
    String? waiterName,
    String? bookingId,
    String? roomId,
    String? guestName,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      openedAt: openedAt ?? this.openedAt,
      paxCount: paxCount ?? this.paxCount,
      priority: priority ?? this.priority,
      orderNotes: orderNotes ?? this.orderNotes,
      createdBy: createdBy ?? this.createdBy,
      waiterName: waiterName ?? this.waiterName,
      bookingId: bookingId ?? this.bookingId,
      roomId: roomId ?? this.roomId,
      guestName: guestName ?? this.guestName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'items': items.map((i) => i.toJson()).toList(),
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (openedAt != null) 'openedAt': openedAt!.toIso8601String(),
      'paxCount': paxCount,
      'priority': priority.name,
      'orderNotes': orderNotes,
      'createdBy': createdBy,
      'waiterName': waiterName,
      'bookingId': bookingId,
      'roomId': roomId,
      'guestName': guestName,
      'paymentMethod': paymentMethod?.name,
      'paymentStatus': paymentStatus.name,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['tableId'],
      tableNumber: json['tableNumber'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'])
          : null,
      paxCount: json['paxCount'] ?? 1,
      priority: OrderPriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'normal'),
      ),
      orderNotes: json['orderNotes'],
      createdBy: json['createdBy'],
      waiterName: json['waiterName'],
      bookingId: json['bookingId'],
      roomId: json['roomId'],
      guestName: json['guestName'],
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
            )
          : null,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
    );
  }
}

class OrderItem extends Equatable {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final List<OrderItemOption>? options;
  final KdsStatus kdsStatus;
  final DateTime? firedAt;
  final CourseType course;
  final int expectedPrepTimeMinutes;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.notes,
    this.options,
    this.kdsStatus = KdsStatus.pending,
    this.firedAt,
    this.course = CourseType.mains,
    this.expectedPrepTimeMinutes = 15,
  });

  @override
  List<Object?> get props => [
    id,
    menuItemId,
    name,
    price,
    quantity,
    notes,
    options,
    kdsStatus,
    firedAt,
    course,
    expectedPrepTimeMinutes,
  ];

  double get totalPrice {
    double optPrice = options?.fold(0, (sum, opt) => sum! + opt.price) ?? 0;
    return (price + optPrice) * quantity;
  }

  bool get isDelayed {
    if (firedAt == null ||
        kdsStatus == KdsStatus.served ||
        kdsStatus == KdsStatus.cancelled)
      return false;
    final delay = DateTime.now().difference(firedAt!).inMinutes;
    return delay > expectedPrepTimeMinutes;
  }

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? notes,
    List<OrderItemOption>? options,
    KdsStatus? kdsStatus,
    DateTime? firedAt,
    CourseType? course,
    int? expectedPrepTimeMinutes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      options: options ?? this.options,
      kdsStatus: kdsStatus ?? this.kdsStatus,
      firedAt: firedAt ?? this.firedAt,
      course: course ?? this.course,
      expectedPrepTimeMinutes:
          expectedPrepTimeMinutes ?? this.expectedPrepTimeMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'options': options?.map((o) => o.toJson()).toList(),
      'kdsStatus': kdsStatus.name,
      'firedAt': firedAt?.toIso8601String(),
      'course': course.name,
      'expectedPrepTimeMinutes': expectedPrepTimeMinutes,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      menuItemId: json['menuItemId'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
      notes: json['notes'],
      options: json['options'] != null
          ? (json['options'] as List)
                .map((o) => OrderItemOption.fromJson(o))
                .toList()
          : null,
      kdsStatus: KdsStatus.values.firstWhere(
        (e) => e.name == (json['kdsStatus'] ?? 'pending'),
      ),
      firedAt: json['firedAt'] != null ? DateTime.parse(json['firedAt']) : null,
      course: CourseType.values.firstWhere(
        (e) => e.name == (json['course'] ?? 'mains'),
      ),
      expectedPrepTimeMinutes: json['expectedPrepTimeMinutes'] ?? 15,
    );
  }

  factory OrderItem.fromMenuItem(
    MenuItem item, {
    int quantity = 1,
    String? notes,
    CourseType course = CourseType.mains,
  }) {
    return OrderItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: item.id,
      name: item.name,
      price: item.price,
      quantity: quantity,
      notes: notes,
      course: course,
      expectedPrepTimeMinutes: item.preparationTimeMinutes,
    );
  }
}

class OrderItemOption extends Equatable {
  final String id;
  final String name;
  final double price;

  const OrderItemOption({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  factory OrderItemOption.fromJson(Map<String, dynamic> json) {
    return OrderItemOption(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
