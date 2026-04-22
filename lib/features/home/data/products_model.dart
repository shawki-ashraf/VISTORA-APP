import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subCategory;
  final double price;
  final double oldPrice;
  final double discount;
  final double rating;
  final double? reviewCount;
  final int? stock;
  final bool? isBestSeller;
  final List<String> images;
  final List<String> sizes;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.isBestSeller,
    required this.images,
    required this.sizes,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',

      price: (json['price'] ?? 0).toDouble(),
      oldPrice: (json['oldPrice'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toDouble(),

      stock: (json['stock'] ?? 0).toInt(),
      isBestSeller: json['isBestSeller'] ?? false,

      images: json['images'] != null ? List<String>.from(json['images']) : [],

      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],

      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isBestSeller': isBestSeller,
      'images': images,
      'sizes': sizes,
      'createdAt': createdAt,
    };
  }
}
