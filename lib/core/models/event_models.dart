import 'package:equatable/equatable.dart';
import 'base_entity.dart';

/// Hall/Area configuration model
class Hall extends BaseEntity {
  final String name;
  final int capacity;
  final String? description;
  final List<String> featureIds;
  final bool isActive;

  const Hall({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.capacity,
    this.description,
    this.featureIds = const [],
    this.isActive = true,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime? get createdAt => createdOn;

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    capacity,
    description,
    featureIds,
    isActive,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'name': name,
    'capacity': capacity,
    'description': description,
    'featureIds': featureIds,
    'isActive': isActive,
  };

  factory Hall.fromJson(Map<String, dynamic> json) => Hall(
    id: json['id'],
    hotelId: json['hotelId'] as String? ?? 'default',
    name: json['name'],
    capacity: (json['capacity'] as num).toInt(),
    description: json['description'],
    featureIds: List<String>.from(json['featureIds'] ?? []),
    isActive: json['isActive'] ?? true,
    createdBy: json['createdBy'],
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'],
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );

  Hall copyWith({
    String? id,
    String? hotelId,
    String? name,
    int? capacity,
    String? description,
    List<String>? featureIds,
    bool? isActive,
  }) {
    return Hall(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      featureIds: featureIds ?? this.featureIds,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }
}

/// Hall Feature configuration (e.g., DJ, Decoration)
class HallFeature extends BaseEntity {
  final String name;
  final String? description;
  final int? iconCode;
  final double defaultPrice;
  final bool isActive;

  const HallFeature({
    required super.id,
    required super.hotelId,
    required this.name,
    this.description,
    this.iconCode,
    this.defaultPrice = 0.0,
    this.isActive = true,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    description,
    iconCode,
    defaultPrice,
    isActive,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'name': name,
    'description': description,
    'iconCode': iconCode,
    'defaultPrice': defaultPrice,
    'isActive': isActive,
  };

  factory HallFeature.fromJson(Map<String, dynamic> json) => HallFeature(
    id: json['id'],
    hotelId: json['hotelId'] as String? ?? 'default',
    name: json['name'],
    description: json['description'],
    iconCode: json['iconCode'],
    defaultPrice: (json['defaultPrice'] as num?)?.toDouble() ?? 0.0,
    isActive: json['isActive'] ?? true,
    createdBy: json['createdBy'],
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'],
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );
}

/// Selection of a feature for a specific event
class EventFeatureSelection extends Equatable {
  final String featureId;
  final bool isSelected;
  final String? arrangement; // 'customer' or 'management'

  const EventFeatureSelection({
    required this.featureId,
    this.isSelected = false,
    this.arrangement,
  });

  @override
  List<Object?> get props => [featureId, isSelected, arrangement];

  Map<String, dynamic> toJson() => {
    'featureId': featureId,
    'isSelected': isSelected,
    'arrangement': arrangement,
  };

  factory EventFeatureSelection.fromJson(Map<String, dynamic> json) =>
      EventFeatureSelection(
        featureId: json['featureId'],
        isSelected: json['isSelected'] ?? false,
        arrangement: json['arrangement'],
      );

  EventFeatureSelection copyWith({
    String? featureId,
    bool? isSelected,
    String? arrangement,
  }) {
    return EventFeatureSelection(
      featureId: featureId ?? this.featureId,
      isSelected: isSelected ?? this.isSelected,
      arrangement: arrangement ?? this.arrangement,
    );
  }
}

/// Event status enum
enum EventStatus { draft, confirmed, live, closed, billed, archived }

/// Pricing category enum
enum PricingCategory { perPax, package, itemized, hybrid }

/// Pricing details for an event
class EventPricing extends Equatable {
  final PricingCategory category;
  final double basePrice;
  final double perPaxRate;
  final List<EventAddOn> addOns;
  final double? manualPrice;
  final String? taxRuleId;

  const EventPricing({
    required this.category,
    this.basePrice = 0.0,
    this.perPaxRate = 0.0,
    this.addOns = const [],
    this.manualPrice,
    this.taxRuleId,
  });

  @override
  List<Object?> get props => [
    category,
    basePrice,
    addOns,
    manualPrice,
    taxRuleId,
  ];

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'basePrice': basePrice,
    'perPaxRate': perPaxRate,
    'addOns': addOns.map((e) => e.toJson()).toList(),
    'manualPrice': manualPrice,
    'taxRuleId': taxRuleId,
  };

  factory EventPricing.fromJson(Map<String, dynamic> json) => EventPricing(
    category: PricingCategory.values.firstWhere(
      (e) => e.name == json['category'],
    ),
    basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
    perPaxRate: (json['perPaxRate'] as num?)?.toDouble() ?? 0.0,
    addOns:
        (json['addOns'] as List?)
            ?.map((e) => EventAddOn.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [],
    manualPrice: (json['manualPrice'] as num?)?.toDouble(),
    taxRuleId: json['taxRuleId'],
  );

  EventPricing copyWith({
    PricingCategory? category,
    double? basePrice,
    double? perPaxRate,
    List<EventAddOn>? addOns,
    double? manualPrice,
    String? taxRuleId,
  }) {
    return EventPricing(
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      perPaxRate: perPaxRate ?? this.perPaxRate,
      addOns: addOns ?? this.addOns,
      manualPrice: manualPrice ?? this.manualPrice,
      taxRuleId: taxRuleId ?? this.taxRuleId,
    );
  }
}

/// Dynamic add-on for event pricing
class EventAddOn extends Equatable {
  final String name;
  final double price;

  const EventAddOn({required this.name, required this.price});

  @override
  List<Object?> get props => [name, price];

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  factory EventAddOn.fromJson(Map<String, dynamic> json) =>
      EventAddOn(name: json['name'], price: (json['price'] as num).toDouble());
}

/// Core Event Entity
class PrivateEvent extends BaseEntity {
  final String name;
  final String guestName;
  final String guestPhone;
  final DateTime date;
  final String startTime;
  final String endTime;
  final List<String> hallIds;
  final List<String> menuItemIds;
  final int expectedPax;
  final EventStatus status;
  final EventPricing pricing;
  final double advancePayment;
  final String? notes;
  final List<EventFeatureSelection> featureSelections;

  const PrivateEvent({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.guestName,
    required this.guestPhone,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hallIds,
    this.menuItemIds = const [],
    required this.expectedPax,
    required this.status,
    required this.pricing,
    this.advancePayment = 0.0,
    this.notes,
    this.featureSelections = const [],
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime? get createdAt => createdOn;

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    guestName,
    guestPhone,
    date,
    startTime,
    endTime,
    hallIds,
    menuItemIds,
    expectedPax,
    status,
    pricing,
    advancePayment,
    notes,
    featureSelections,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'name': name,
    'guestName': guestName,
    'guestPhone': guestPhone,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'hallIds': hallIds,
    'menuItemIds': menuItemIds,
    'expectedPax': expectedPax,
    'status': status.name,
    'pricing': pricing.toJson(),
    'advancePayment': advancePayment,
    'notes': notes,
    'featureSelections': featureSelections.map((e) => e.toJson()).toList(),
  };

  factory PrivateEvent.fromJson(Map<String, dynamic> json) {
    final selections = <EventFeatureSelection>[];
    if (json['featureSelections'] != null) {
      selections.addAll(
        (json['featureSelections'] as List).map(
          (e) => EventFeatureSelection.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    } else {
      // Migration logic for older fields
      if (json['requiresDJ'] == true) {
        selections.add(
          EventFeatureSelection(
            featureId: 'dj',
            isSelected: true,
            arrangement: json['djArrangement'],
          ),
        );
      }
      if (json['requiresDecoration'] == true) {
        selections.add(
          EventFeatureSelection(
            featureId: 'decoration',
            isSelected: true,
            arrangement: json['decorationArrangement'],
          ),
        );
      }
    }

    return PrivateEvent(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      name: json['name'] as String,
      guestName: json['guestName'] as String,
      guestPhone: json['guestPhone'] as String,
      date: BaseEntity.parseDateTime(json['date']) ?? DateTime.now(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      hallIds: List<String>.from(json['hallIds'] as List),
      menuItemIds: List<String>.from(json['menuItemIds'] ?? []),
      expectedPax: json['expectedPax'] as int,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.confirmed,
      ),
      pricing: EventPricing.fromJson(
        Map<String, dynamic>.from(json['pricing']),
      ),
      advancePayment: (json['advancePayment'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
      featureSelections: selections,
    );
  }

  PrivateEvent copyWith({
    String? id,
    String? hotelId,
    String? name,
    String? guestName,
    String? guestPhone,
    DateTime? date,
    String? startTime,
    String? endTime,
    List<String>? hallIds,
    List<String>? menuItemIds,
    int? expectedPax,
    EventStatus? status,
    EventPricing? pricing,
    double? advancePayment,
    String? notes,
    List<EventFeatureSelection>? featureSelections,
  }) {
    return PrivateEvent(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hallIds: hallIds ?? this.hallIds,
      menuItemIds: menuItemIds ?? this.menuItemIds,
      expectedPax: expectedPax ?? this.expectedPax,
      status: status ?? this.status,
      pricing: pricing ?? this.pricing,
      advancePayment: advancePayment ?? this.advancePayment,
      notes: notes ?? this.notes,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
      featureSelections: featureSelections ?? this.featureSelections,
    );
  }
}

/// Event Staff Assignment
class EventStaffAssignment extends BaseEntity {
  final String eventId;
  final String managerId; // Reference to Employee
  final List<String> staffIds; // List of Employee IDs

  const EventStaffAssignment({
    required super.id,
    required super.hotelId,
    required this.eventId,
    required this.managerId,
    this.staffIds = const [],
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [...super.props, eventId, managerId, staffIds];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'eventId': eventId,
    'managerId': managerId,
    'staffIds': staffIds,
  };

  factory EventStaffAssignment.fromJson(Map<String, dynamic> json) =>
      EventStaffAssignment(
        id: json['id'],
        hotelId: json['hotelId'] ?? 'default',
        eventId: json['eventId'],
        managerId: json['managerId'],
        staffIds: List<String>.from(json['staffIds'] ?? []),
        createdBy: json['createdBy'],
        createdOn: BaseEntity.parseDateTime(json['createdOn']),
        updatedBy: json['updatedBy'],
        updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
        isDeleted: json['isDeleted'] ?? false,
      );

  EventStaffAssignment copyWith({
    String? id,
    String? hotelId,
    String? eventId,
    String? managerId,
    List<String>? staffIds,
  }) {
    return EventStaffAssignment(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      eventId: eventId ?? this.eventId,
      managerId: managerId ?? this.managerId,
      staffIds: staffIds ?? this.staffIds,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }
}

/// Event-specific Purchase Order
class EventPO extends BaseEntity {
  final String eventId;
  final String vendorId;
  final String description;
  final double cost;
  final bool isPaid;
  final bool isPassedToCustomer;

  const EventPO({
    required super.id,
    required super.hotelId,
    required this.eventId,
    required this.vendorId,
    required this.description,
    required this.cost,
    this.isPaid = false,
    this.isPassedToCustomer = false,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    eventId,
    vendorId,
    description,
    cost,
    isPaid,
    isPassedToCustomer,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'eventId': eventId,
    'vendorId': vendorId,
    'description': description,
    'cost': cost,
    'isPaid': isPaid,
    'isPassedToCustomer': isPassedToCustomer,
  };

  factory EventPO.fromJson(Map<String, dynamic> json) => EventPO(
    id: json['id'],
    hotelId: json['hotelId'] ?? 'default',
    eventId: json['eventId'],
    vendorId: json['vendorId'],
    description: json['description'],
    cost: (json['cost'] as num).toDouble(),
    isPaid: json['isPaid'] ?? false,
    isPassedToCustomer: json['isPassedToCustomer'] ?? false,
    createdBy: json['createdBy'],
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'],
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );
}

/// Event Incident Model for tracking damages or extra services
class EventIncident extends BaseEntity {
  final String eventId;
  final String title;
  final String description;
  final DateTime timestamp;
  final String reportedBy;
  final double financialImpact;
  final bool isResolved;

  const EventIncident({
    required super.id,
    required super.hotelId,
    required this.eventId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.reportedBy,
    this.financialImpact = 0.0,
    this.isResolved = false,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    eventId,
    title,
    description,
    timestamp,
    reportedBy,
    financialImpact,
    isResolved,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'eventId': eventId,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'reportedBy': reportedBy,
    'financialImpact': financialImpact,
    'isResolved': isResolved,
  };

  factory EventIncident.fromJson(Map<String, dynamic> json) => EventIncident(
    id: json['id'],
    hotelId: json['hotelId'] ?? 'default',
    eventId: json['eventId'],
    title: json['title'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    reportedBy: json['reportedBy'],
    financialImpact: (json['financialImpact'] as num?)?.toDouble() ?? 0.0,
    isResolved: json['isResolved'] ?? false,
    createdBy: json['createdBy'],
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'],
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );

  EventIncident copyWith({
    String? id,
    String? hotelId,
    String? eventId,
    String? title,
    String? description,
    DateTime? timestamp,
    String? reportedBy,
    double? financialImpact,
    bool? isResolved,
  }) {
    return EventIncident(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      reportedBy: reportedBy ?? this.reportedBy,
      financialImpact: financialImpact ?? this.financialImpact,
      isResolved: isResolved ?? this.isResolved,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }
}
