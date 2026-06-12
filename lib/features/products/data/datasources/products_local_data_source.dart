import 'package:hive/hive.dart';

import '../models/product_category_model.dart';
import '../models/product_model.dart';

class ProductsLocalDataSource {
  const ProductsLocalDataSource(this._box);

  final Box<dynamic> _box;

  Future<void> cacheProducts({
    required List<ProductModel> products,
    required int total,
    String? categorySlug,
  }) async {
    final cachedProducts = await getCachedProducts(categorySlug: categorySlug);
    final merged = <int, ProductModel>{
      for (final product in cachedProducts) product.id: product,
      for (final product in products) product.id: product,
    };

    final scope = _scope(categorySlug);
    await _box.put(
      _productsKey(scope),
      merged.values.map((product) => product.toJson()).toList(growable: false),
    );
    await _box.put(_totalKey(scope), total);
    await _box.put(_cachedAtKey(scope), DateTime.now().toIso8601String());
  }

  Future<List<ProductModel>> getCachedProducts({String? categorySlug}) async {
    final raw = _box.get(_productsKey(_scope(categorySlug)));
    if (raw is! List) return const <ProductModel>[];

    return raw
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  int getCachedTotal({String? categorySlug}) {
    final total = _box.get(_totalKey(_scope(categorySlug)));
    return total is int ? total : 0;
  }

  Future<void> cacheCategories(List<ProductCategoryModel> categories) async {
    await _box.put(
      'categories',
      categories.map((category) => category.toJson()).toList(growable: false),
    );
  }

  List<ProductCategoryModel> getCachedCategories() {
    final raw = _box.get('categories');
    if (raw is! List) return const <ProductCategoryModel>[];

    return raw
        .whereType<Map>()
        .map(
          (item) =>
              ProductCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  String _scope(String? categorySlug) =>
      categorySlug == null || categorySlug.isEmpty ? 'all' : categorySlug;

  String _productsKey(String scope) => 'products_$scope';

  String _totalKey(String scope) => 'total_$scope';

  String _cachedAtKey(String scope) => 'cached_at_$scope';
}
