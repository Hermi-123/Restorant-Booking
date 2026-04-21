import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
    );
  }
}

class Category {
  final int id;
  final String name;
  final List<MenuItem> items;

  Category({required this.id, required this.name, required this.items});

  factory Category.fromJson(Map<String, dynamic> json) {
    var itemsList = json['menu_items'] as List? ?? [];
    List<MenuItem> items = itemsList.map((i) => MenuItem.fromJson(i)).toList();
    return Category(
      id: json['id'],
      name: json['name'],
      items: items,
    );
  }
}

final menuProvider = FutureProvider<List<Category>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('menu');
  
  if (response.statusCode == 200) {
    List data = response.data;
    return data.map((json) => Category.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load menu');
  }
});
