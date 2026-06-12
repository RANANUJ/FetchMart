import 'package:fetchmart/features/products/domain/entities/product.dart';
import 'package:fetchmart/features/products/providers/product_catalog_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCatalogState.visibleProducts', () {
    test('keeps loaded order for the default popular view', () {
      final state = ProductCatalogState(
        products: [
          _product(3, rating: 5),
          _product(1, rating: 1),
          _product(2, rating: 3),
        ],
      );

      expect(state.visibleProducts.map((product) => product.id), [3, 1, 2]);
    });

    test('uses product id as a stable tie breaker for explicit sorts', () {
      final state = ProductCatalogState(
        sortOption: ProductSortOption.rating,
        products: [
          _product(3, rating: 4),
          _product(1, rating: 4),
          _product(2, rating: 4),
        ],
      );

      expect(state.visibleProducts.map((product) => product.id), [1, 2, 3]);
    });
  });
}

Product _product(int id, {double rating = 4}) {
  return Product(
    id: id,
    title: 'Product $id',
    description: 'Description $id',
    category: 'category',
    price: id.toDouble(),
    rating: rating,
    stock: id,
    thumbnail: 'https://example.com/products/$id.png',
    images: const [],
  );
}
