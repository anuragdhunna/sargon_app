import 'package:equatable/equatable.dart';

enum MenuCategory { starter, mainCourse, dessert, drink, alcohol }

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String imageUrl;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, description, price, category, imageUrl];
}
