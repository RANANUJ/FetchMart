import '../../../../core/network/api_exception.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
    required ProductsLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource;

  @override
  Future<ProductPage> getProducts({
    required int limit,
    required int skip,
    String? categorySlug,
  }) async {
    try {
      final response = await _remoteDataSource.fetchProducts(
        limit: limit,
        skip: skip,
        categorySlug: categorySlug,
      );
      await _localDataSource.cacheProducts(
        products: response.products,
        total: response.total,
        categorySlug: categorySlug,
      );

      return ProductPage(products: response.products, total: response.total);
    } on ApiException {
      if (skip == 0) {
        final cachedProducts = await _localDataSource.getCachedProducts(
          categorySlug: categorySlug,
        );
        if (cachedProducts.isNotEmpty) {
          final total = _localDataSource.getCachedTotal(
            categorySlug: categorySlug,
          );
          return ProductPage(
            products: cachedProducts,
            total: total == 0 ? cachedProducts.length : total,
            isFromCache: true,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final categories = await _remoteDataSource.fetchCategories();
      await _localDataSource.cacheCategories(categories);
      return categories;
    } on ApiException {
      final cachedCategories = _localDataSource.getCachedCategories();
      if (cachedCategories.isNotEmpty) return cachedCategories;
      rethrow;
    }
  }
}
