import '../entities/product_category.dart';
import '../entities/product_page.dart';

abstract interface class ProductsRepository {
  Future<ProductPage> getProducts({
    required int limit,
    required int skip,
    String? categorySlug,
  });

  Future<List<ProductCategory>> getCategories();
}
