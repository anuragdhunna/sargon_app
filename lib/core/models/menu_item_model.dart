import 'package:equatable/equatable.dart';
import 'recipe_model.dart';

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
/// Dietary preference type
enum DietaryType { veg, nonVeg, eggiterian }

extension DietaryTypeExtension on DietaryType {
  String get displayName {
    switch (this) {
      case DietaryType.veg:
        return 'Veg';
      case DietaryType.nonVeg:
        return 'Non-Veg';
      case DietaryType.eggiterian:
        return 'Eggiterian';
    }
  }
}

/// MenuItem model representing a dish/drink on the menu
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 2
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String imageUrl;
  final bool isAvailable;
  final DietaryType dietaryType; // Replaces isVegetarian
  final int preparationTimeMinutes;
  final String? notes; // Order-specific notes
  final List<RecipeIngredient>? recipe; // Ingredients for stock deduction

  // Schema version for migrations
  static const int schemaVersion = 2;

  const MenuItem({
    required this.id,
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
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    String? imageUrl,
    bool? isAvailable,
    DietaryType? dietaryType,
    int? preparationTimeMinutes,
    String? notes,
    List<RecipeIngredient>? recipe,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      dietaryType: dietaryType ?? this.dietaryType,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      notes: notes ?? this.notes,
      recipe: recipe ?? this.recipe,
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
      'dietaryType': dietaryType.name,
      'preparationTimeMinutes': preparationTimeMinutes,
      'notes': notes,
      'recipe': recipe?.map((r) => r.toJson()).toList(),
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Migration for isVegetarian
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
    dietaryType,
    preparationTimeMinutes,
    notes,
    recipe,
  ];
}
