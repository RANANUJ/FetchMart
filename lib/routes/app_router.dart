import 'package:flutter/material.dart';

import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/products/domain/entities/product.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';

abstract final class AppRouter {
  static Route<void> productDetail(Product product) {
    return MaterialPageRoute<void>(
      builder: (_) => ProductDetailScreen(product: product),
    );
  }

  static Route<void> wishlist() {
    return MaterialPageRoute<void>(builder: (_) => const WishlistScreen());
  }

  static Route<void> cart() {
    return MaterialPageRoute<void>(builder: (_) => const CartScreen());
  }
}
