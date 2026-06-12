import '../entities/product_category.dart';
import '../repositories/products_repository.dart';

class GetProductCategories {
  const GetProductCategories(this._repository);

  final ProductsRepository _repository;

  Future<List<ProductCategory>> call() => _repository.getCategories();
}
