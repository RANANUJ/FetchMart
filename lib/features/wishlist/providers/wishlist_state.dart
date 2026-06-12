import '../../products/domain/entities/product.dart';

class WishlistState {
  const WishlistState({
    this.products = const <Product>[],
    this.productIds = const <int>{},
  });

  final List<Product> products;
  final Set<int> productIds;

  bool contains(int productId) => productIds.contains(productId);
}
