import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.rating,
    required super.stock,
    required super.thumbnail,
    required super.images,
    super.brand,
    super.discountPercentage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _asInt(json['id']),
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'uncategorized',
      price: _asDouble(json['price']),
      rating: _asDouble(json['rating']),
      stock: _asInt(json['stock']),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      brand: json['brand'] as String?,
      discountPercentage: _asDouble(json['discountPercentage']),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      category: product.category,
      price: product.price,
      rating: product.rating,
      stock: product.stock,
      thumbnail: product.thumbnail,
      images: product.images,
      brand: product.brand,
      discountPercentage: product.discountPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'thumbnail': thumbnail,
      'images': images,
      'brand': brand,
      'discountPercentage': discountPercentage,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
