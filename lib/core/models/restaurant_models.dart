import 'base_entity.dart';
import 'recipe_model.dart';
import 'promotion_models.dart';

/// Table status enum
enum TableStatus { available, occupied, billed, cleaning, reserved }

/// Extension for TableStatus
extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.billed:
        return 'Billed';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }
}

/// Table model
class TableEntity extends BaseEntity {
  final String name;
  final String tableCode;
  final int minCapacity;
  final int maxCapacity;
  final List<String> joinableTableIds;
  final TableStatus status;
  final bool isBarTable;
  final bool isActive;
  final String? currentGroupId;

  const TableEntity({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.tableCode,
    this.minCapacity = 1,
    required this.maxCapacity,
    this.joinableTableIds = const [],
    this.status = TableStatus.available,
    this.isBarTable = false,
    this.isActive = true,
    this.currentGroupId,
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
    tableCode,
    minCapacity,
    maxCapacity,
    joinableTableIds,
    status,
    isBarTable,
    isActive,
    currentGroupId,
  ];

  TableEntity copyWith({
    String? id,
    String? hotelId,
    TableStatus? status,
    String? currentGroupId,
  }) {
    return TableEntity(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name,
      tableCode: tableCode,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      joinableTableIds: joinableTableIds,
      status: status ?? this.status,
      isBarTable: isBarTable,
      isActive: isActive,
      currentGroupId: currentGroupId ?? this.currentGroupId,
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
      'name': name,
      'tableCode': tableCode,
      'minCapacity': minCapacity,
      'maxCapacity': maxCapacity,
      'joinableTableIds': joinableTableIds,
      'status': status.name,
      'isBarTable': isBarTable,
      'isActive': isActive,
      'currentGroupId': currentGroupId,
    };
  }

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotelId'] as String? ?? 'default',
      name: json['name'] as String? ?? json['tableCode']?.toString() ?? 'Table',
      tableCode: json['tableCode']?.toString() ?? 'T-?',
      minCapacity: (json['minCapacity'] as num?)?.toInt() ?? 1,
      maxCapacity:
          (json['maxCapacity'] as num?)?.toInt() ??
          (json['capacity'] as num?)?.toInt() ??
          4,
      joinableTableIds: List<String>.from(json['joinableTableIds'] ?? []),
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      isBarTable: json['isBarTable'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      currentGroupId: json['currentGroupId']?.toString(),
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Menu categories
enum MenuCategory { starter, mainCourse, dessert, drink, alcohol }

/// Extension for MenuCategory
extension MenuCategoryExtension on MenuCategory {
  String get displayName {
    switch (this) {
      case MenuCategory.starter:
        return 'Starter';
      case MenuCategory.mainCourse:
        return 'Main Course';
      case MenuCategory.dessert:
        return 'Dessert';
      case MenuCategory.drink:
        return 'Drink';
      case MenuCategory.alcohol:
        return 'Alcohol';
    }
  }
}

/// Dietary type
enum DietaryType { veg, nonVeg, eggiterian }

/// Extension for DietaryType
extension DietaryTypeExtension on DietaryType {
  String get displayName {
    switch (this) {
      case DietaryType.veg:
        return 'Vegetarian';
      case DietaryType.nonVeg:
        return 'Non-Vegetarian';
      case DietaryType.eggiterian:
        return 'Eggiterian';
    }
  }
}

/// MenuItem model
class MenuItem extends BaseEntity {
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String imageUrl;
  final bool isAvailable;
  final DietaryType dietaryType;
  final int preparationTimeMinutes;
  final String? notes;
  final List<RecipeIngredient>? recipe;

  const MenuItem({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.dietaryType = DietaryType.veg,
    this.preparationTimeMinutes = 15,
    this.notes,
    this.recipe,
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
    price,
    category,
    imageUrl,
    isAvailable,
    dietaryType,
    preparationTimeMinutes,
    notes,
    recipe,
  ];

  MenuItem copyWith({
    String? id,
    String? hotelId,
    String? name,
    double? price,
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      description: description,
      price: price ?? this.price,
      category: category,
      imageUrl: imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      dietaryType: dietaryType,
      preparationTimeMinutes: preparationTimeMinutes,
      notes: notes,
      recipe: recipe,
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
      'name': name,
      'description': description,
      'price': price,
      'category': category.name,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'dietaryType': dietaryType.name,
      'preparationTimeMinutes': preparationTimeMinutes,
      'notes': notes,
      'recipe': recipe?.map((r) => r.toJson()).toList(),
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    DietaryType dietaryType = DietaryType.veg;
    if (json['dietaryType'] != null) {
      dietaryType = DietaryType.values.firstWhere(
        (e) => e.name == json['dietaryType'],
        orElse: () => DietaryType.veg,
      );
    } else if (json['isVegetarian'] != null) {
      dietaryType = (json['isVegetarian'] as bool)
          ? DietaryType.veg
          : DietaryType.nonVeg;
    }

    return MenuItem(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: MenuCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MenuCategory.mainCourse,
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      dietaryType: dietaryType,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 15,
      notes: json['notes'] as String?,
      recipe: (json['recipe'] as List?)
          ?.map((e) => RecipeIngredient.fromJson(e))
          .toList(),
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Happy Hour Configuration
class HappyHour extends BaseEntity {
  final String name;
  final List<String> applicableDays;
  final String startTime;
  final String endTime;
  final List<String> applicableCategoryIds;
  final List<String> applicableItemIds;
  final DiscountType? discountType;
  final double discountValue;
  final bool autoApply;
  final bool isActive;
  final int priority;

  const HappyHour({
    required super.id,
    required super.hotelId,
    required this.name,
    required this.applicableDays,
    required this.startTime,
    required this.endTime,
    this.applicableCategoryIds = const [],
    this.applicableItemIds = const [],
    this.discountType,
    required this.discountValue,
    this.autoApply = true,
    this.isActive = true,
    this.priority = 0,
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
    applicableDays,
    startTime,
    endTime,
    discountValue,
    discountValue,
    isActive,
    priority,
  ];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toAuditJson(),
    'name': name,
    'applicableDays': applicableDays,
    'startTime': startTime,
    'endTime': endTime,
    'applicableCategoryIds': applicableCategoryIds,
    'applicableItemIds': applicableItemIds,
    'discountType': discountType?.name,
    'discountValue': discountValue,
    'autoApply': autoApply,
    'isActive': isActive,
    'priority': priority,
  };

  factory HappyHour.fromJson(Map<String, dynamic> json) => HappyHour(
    id: json['id'],
    hotelId: json['hotelId'] as String? ?? 'default',
    name: json['name'],
    applicableDays: List<String>.from(json['applicableDays'] ?? []),
    startTime: json['startTime'],
    endTime: json['endTime'],
    applicableCategoryIds: List<String>.from(
      json['applicableCategoryIds'] ?? [],
    ),
    applicableItemIds: List<String>.from(json['applicableItemIds'] ?? []),
    discountType: json['discountType'] != null
        ? DiscountType.values.firstWhere(
            (e) => e.name == json['discountType'],
            orElse: () => DiscountType.percent,
          )
        : null,
    discountValue: (json['discountValue'] as num).toDouble(),
    autoApply: json['autoApply'] ?? true,
    isActive: json['isActive'] ?? true,
    priority: json['priority'] ?? 0,
    createdBy: json['createdBy'] as String?,
    createdOn: BaseEntity.parseDateTime(json['createdOn']),
    updatedBy: json['updatedBy'] as String?,
    updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
    isDeleted: json['isDeleted'] ?? false,
  );
}
