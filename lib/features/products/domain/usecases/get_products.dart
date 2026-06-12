import '../entities/product_page.dart';
import '../repositories/products_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductsRepository _repository;

  Future<ProductPage> call({
    required int limit,
    required int skip,
    String? categorySlug,
  }) {
    return _repository.getProducts(
      limit: limit,
      skip: skip,
      categorySlug: categorySlug,
    );
  }
}
