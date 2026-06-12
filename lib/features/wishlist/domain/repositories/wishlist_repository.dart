import '../../../products/domain/entities/product.dart';

abstract interface class WishlistRepository {
  List<Product> getAll();

  Future<void> add(Product product);

  Future<void> remove(int productId);

  bool contains(int productId);
}
