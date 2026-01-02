import 'package:equatable/equatable.dart';

/// Menu item categories
enum MenuCategory { starter, mainCourse, dessert, drink, alcohol }

/// Extension for MenuCategory display names
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

/// MenuItem model representing a dish/drink on the menu
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String imageUrl;
  final bool isAvailable;
  final bool isVegetarian;
  final int preparationTimeMinutes;
  final String? notes; // Order-specific notes

  // Schema version for migrations
  static const int schemaVersion = 1;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.isVegetarian = false,
    this.preparationTimeMinutes = 15,
    this.notes,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    String? imageUrl,
    bool? isAvailable,
    bool? isVegetarian,
    int? preparationTimeMinutes,
    String? notes,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.name,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isVegetarian': isVegetarian,
      'preparationTimeMinutes': preparationTimeMinutes,
      'notes': notes,
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: MenuCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MenuCategory.mainCourse,
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 15,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    imageUrl,
    isAvailable,
    isVegetarian,
    preparationTimeMinutes,
    notes,
  ];
}
