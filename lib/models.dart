import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final IconData icon;

  Category({required this.id, required this.title, required this.icon});
}

class Marketplace {
  final String id;
  final String name;
  final String categoryId;
  final String image;
  final String description;

  Marketplace({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.image,
    this.description = "",
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String marketplaceId;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.marketplaceId,
    required this.imageUrl,
  });
}

enum OrderStatus { placed, accepted, packing, pickedUp, delivered, cancelled }

class Order {
  final String id;
  final String customerId;
  final String marketplaceId;
  final String? agentId;
  final String productName;
  final double price;
  final String remarks;
  final String location;
  final OrderStatus status;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.customerId,
    required this.marketplaceId,
    this.agentId,
    required this.productName,
    required this.price,
    required this.remarks,
    required this.location,
    required this.status,
    required this.timestamp,
  });
}

class Review {
  final String id;
  final String targetId; // Marketplace ID or Driver ID
  final String customerName;
  final double rating; // e.g. 5.0
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.targetId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}

class Discount {
  final String id;
  final String marketplaceId;
  final String title;
  final double percentage; // e.g., 15.0 for 15% off
  bool isActive;

  Discount({
    required this.id,
    required this.marketplaceId,
    required this.title,
    required this.percentage,
    this.isActive = true,
  });
}

class AppData {
  static List<Category> categories = [
    Category(id: '1', title: 'Restaurants', icon: Icons.restaurant),
    Category(id: '2', title: 'Supermarkets', icon: Icons.local_grocery_store),
    Category(id: '3', title: 'Pharmacies', icon: Icons.local_pharmacy),
    Category(id: '4', title: 'Electronics', icon: Icons.devices),
  ];

  static List<Marketplace> marketplaces = [
    Marketplace(
      id: 'm1',
      name: "Pizza Palace",
      categoryId: '1',
      image: "https://picsum.photos/seed/pizza/200",
    ),
    Marketplace(
      id: 'm2',
      name: "Burger King",
      categoryId: '1',
      image: "https://picsum.photos/seed/burger/200",
    ),
    Marketplace(
      id: 'm3',
      name: "Fresh Mart",
      categoryId: '2',
      image: "https://picsum.photos/seed/groceries/200",
    ),
  ];

  static List<Product> products = [
    Product(
      id: 'p1',
      name: 'Margherita Pizza',
      price: 12.99,
      marketplaceId: 'm1',
      imageUrl: 'https://picsum.photos/seed/piz1/200',
    ),
    Product(
      id: 'p2',
      name: 'Pepperoni Pizza',
      price: 15.99,
      marketplaceId: 'm1',
      imageUrl: 'https://picsum.photos/seed/piz2/200',
    ),
    Product(
      id: 'p3',
      name: 'Whopper Burger',
      price: 8.50,
      marketplaceId: 'm2',
      imageUrl: 'https://picsum.photos/seed/burger1/200',
    ),
    Product(
      id: 'p4',
      name: 'Milk 1L',
      price: 2.20,
      marketplaceId: 'm3',
      imageUrl: 'https://picsum.photos/seed/milk/200',
    ),
  ];

  static List<Discount> discounts = [
    Discount(
      id: 'd1',
      marketplaceId: 'm1',
      title: 'Weekend Flash Sale',
      percentage: 15.0,
      isActive: true,
    ),
  ];

  static List<Order> myOrders = [];
}
