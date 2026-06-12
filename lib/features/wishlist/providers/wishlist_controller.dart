import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/domain/entities/product.dart';
import '../domain/repositories/wishlist_repository.dart';
import 'wishlist_state.dart';

class WishlistController extends StateNotifier<WishlistState> {
  WishlistController(this._repository) : super(const WishlistState()) {
    load();
  }

  final WishlistRepository _repository;

  void load() {
    final products = _repository.getAll();
    state = WishlistState(
      products: products,
      productIds: products.map((product) => product.id).toSet(),
    );
  }

  Future<void> toggle(Product product) async {
    if (state.contains(product.id)) {
      await _repository.remove(product.id);
    } else {
      await _repository.add(product);
    }
    load();
  }

  Future<void> remove(int productId) async {
    await _repository.remove(productId);
    load();
  }
}
