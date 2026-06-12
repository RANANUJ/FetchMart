import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_category_model.dart';
import '../models/products_response_model.dart';

abstract interface class ProductsRemoteDataSource {
  Future<ProductsResponseModel> fetchProducts({
    required int limit,
    required int skip,
    String? categorySlug,
  });

  Future<List<ProductCategoryModel>> fetchCategories();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  const ProductsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProductsResponseModel> fetchProducts({
    required int limit,
    required int skip,
    String? categorySlug,
  }) async {
    final path = categorySlug == null
        ? ApiConstants.products
        : '${ApiConstants.products}/category/$categorySlug';
    final response = await _apiClient.get(
      path,
      queryParameters: {'limit': limit, 'skip': skip},
    );

    return ProductsResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<List<ProductCategoryModel>> fetchCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final items = response.data as List<dynamic>? ?? const <dynamic>[];

    return items.map(ProductCategoryModel.fromJson).toList(growable: false);
  }
}
