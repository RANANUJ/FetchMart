import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    this.isFromCache = false,
  });

  final List<Product> products;
  final int total;
  final bool isFromCache;
}
