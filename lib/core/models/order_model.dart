import 'package:equatable/equatable.dart';
import 'menu_item_model.dart';
import 'payment_models.dart';
import 'offer_model.dart';

/// Overall Order status enum
enum OrderStatus { pending, cooking, ready, served, cancelled }

/// Wrapper to handle null values in copyWith
class Optional<T> {
  final T? value;
  const Optional(this.value);
}

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
  final String? customerId;
  final String? phone;
  final PaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;
  final String? appliedOfferId;
  final String? appliedOfferName;

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
    this.customerId,
    this.phone,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.appliedOfferId,
    this.appliedOfferName,
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
    customerId,
    phone,
    paymentMethod,
    paymentStatus,
    appliedOfferId,
    appliedOfferName,
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
    Optional<String>? orderNotes,
    String? createdBy,
    String? waiterName,
    Optional<String>? bookingId,
    Optional<String>? roomId,
    Optional<String>? guestName,
    Optional<String>? customerId,
    Optional<String>? phone,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    Optional<String>? appliedOfferId,
    Optional<String>? appliedOfferName,
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
      paxCount:
          paxCount ??
          this.paxCount, // paxCount is not optional in current update logic
      priority: priority ?? this.priority,
      orderNotes: orderNotes != null ? orderNotes.value : this.orderNotes,
      createdBy: createdBy ?? this.createdBy,
      waiterName: waiterName ?? this.waiterName,
      bookingId: bookingId != null ? bookingId.value : this.bookingId,
      roomId: roomId != null ? roomId.value : this.roomId,
      guestName: guestName != null ? guestName.value : this.guestName,
      customerId: customerId != null ? customerId.value : this.customerId,
      phone: phone != null ? phone.value : this.phone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      appliedOfferId: appliedOfferId != null
          ? appliedOfferId.value
          : this.appliedOfferId,
      appliedOfferName: appliedOfferName != null
          ? appliedOfferName.value
          : this.appliedOfferName,
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
      'customerId': customerId,
      'phone': phone,
      'paymentMethod': paymentMethod?.name,
      'paymentStatus': paymentStatus.name,
      'appliedOfferId': appliedOfferId,
      'appliedOfferName': appliedOfferName,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] != null ? json['id'].toString() : '',
      tableId: json['tableId'] != null ? json['tableId'].toString() : '',
      tableNumber: json['tableNumber'] != null
          ? json['tableNumber'].toString()
          : '',
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : <OrderItem>[],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'])
          : null,
      paxCount: json['paxCount'] is int
          ? json['paxCount']
          : (json['paxCount'] != null
                ? int.tryParse(json['paxCount'].toString()) ?? 1
                : 1),
      priority: OrderPriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'normal'),
        orElse: () => OrderPriority.normal,
      ),
      orderNotes: json['orderNotes']?.toString(),
      createdBy: json['createdBy']?.toString(),
      waiterName: json['waiterName']?.toString(),
      bookingId: json['bookingId']?.toString(),
      roomId: json['roomId']?.toString(),
      guestName: json['guestName']?.toString(),
      customerId: json['customerId']?.toString(),
      phone: json['phone']?.toString(),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      appliedOfferId: json['appliedOfferId']?.toString(),
      appliedOfferName: json['appliedOfferName']?.toString(),
    );
  }
}

class OrderItem extends Equatable {
  final String id;
  final String menuItemId;
  final String? categoryId;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final List<OrderItemOption>? options;
  final KdsStatus kdsStatus;
  final DateTime? firedAt;
  final CourseType course;
  final int expectedPrepTimeMinutes;
  final double discountAmount;
  final DiscountType? discountType;
  final bool isComplimentary;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    this.categoryId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.notes,
    this.options,
    this.kdsStatus = KdsStatus.pending,
    this.firedAt,
    this.course = CourseType.mains,
    this.expectedPrepTimeMinutes = 15,
    this.discountAmount = 0.0,
    this.discountType,
    this.isComplimentary = false,
  });

  @override
  List<Object?> get props => [
    id,
    menuItemId,
    categoryId,
    name,
    price,
    quantity,
    notes,
    options,
    kdsStatus,
    firedAt,
    course,
    expectedPrepTimeMinutes,
    discountAmount,
    discountType,
    isComplimentary,
  ];

  double get totalPrice {
    if (isComplimentary) return 0.0;
    double optPrice = options?.fold(0, (sum, opt) => sum! + opt.price) ?? 0;
    final baseTotal = (price + optPrice) * quantity;
    return (baseTotal - discountAmount).clamp(0.0, double.infinity);
  }

  bool get isDelayed {
    if (firedAt == null ||
        kdsStatus == KdsStatus.served ||
        kdsStatus == KdsStatus.cancelled) {
      return false;
    }
    final delay = DateTime.now().difference(firedAt!).inMinutes;
    return delay > expectedPrepTimeMinutes;
  }

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    Optional<String>? categoryId,
    String? name,
    double? price,
    int? quantity,
    Optional<String>? notes,
    Optional<List<OrderItemOption>>? options,
    KdsStatus? kdsStatus,
    Optional<DateTime>? firedAt,
    CourseType? course,
    int? expectedPrepTimeMinutes,
    double? discountAmount,
    Optional<DiscountType>? discountType,
    bool? isComplimentary,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      categoryId: categoryId != null ? categoryId.value : this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes != null ? notes.value : this.notes,
      options: options != null ? options.value : this.options,
      kdsStatus: kdsStatus ?? this.kdsStatus,
      firedAt: firedAt != null ? firedAt.value : this.firedAt,
      course: course ?? this.course,
      expectedPrepTimeMinutes:
          expectedPrepTimeMinutes ?? this.expectedPrepTimeMinutes,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType != null
          ? discountType.value
          : this.discountType,
      isComplimentary: isComplimentary ?? this.isComplimentary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'options': options?.map((o) => o.toJson()).toList(),
      'kdsStatus': kdsStatus.name,
      'firedAt': firedAt?.toIso8601String(),
      'course': course.name,
      'expectedPrepTimeMinutes': expectedPrepTimeMinutes,
      'discountAmount': discountAmount,
      if (discountType != null) 'discountType': discountType?.name,
      'isComplimentary': isComplimentary,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      menuItemId: json['menuItemId'],
      categoryId: json['categoryId'],
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
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType'] != null
          ? DiscountType.values.firstWhere(
              (e) => e.name == json['discountType'],
            )
          : null,
      isComplimentary: json['isComplimentary'] ?? false,
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
      categoryId: item.category.name,
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
