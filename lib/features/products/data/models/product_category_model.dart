import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({required super.slug, required super.name});

  factory ProductCategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return ProductCategoryModel(
        slug: json,
        name: Formatters.categoryName(json),
      );
    }

    final map = Map<String, dynamic>.from(json as Map<dynamic, dynamic>);
    final slug = map['slug'] as String? ?? map['name'] as String? ?? '';
    return ProductCategoryModel(
      slug: slug,
      name: map['name'] as String? ?? Formatters.categoryName(slug),
    );
  }

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name};
}
