import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/domain/entities/product.dart';
import '../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartController extends StateNotifier<CartState> {
  CartController(this._repository) : super(const CartState()) {
    load();
  }

  final CartRepository _repository;

  void load() {
    state = CartState(items: _repository.getAll());
  }

  Future<void> add(Product product) async {
    await _repository.add(product);
    load();
  }

  Future<void> increment(int productId) async {
    final currentQuantity = state.quantityFor(productId);
    await updateQuantity(productId: productId, quantity: currentQuantity + 1);
  }

  Future<void> decrement(int productId) async {
    final currentQuantity = state.quantityFor(productId);
    await updateQuantity(productId: productId, quantity: currentQuantity - 1);
  }

  Future<void> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    await _repository.updateQuantity(productId: productId, quantity: quantity);
    load();
  }

  Future<void> remove(int productId) async {
    await _repository.remove(productId);
    load();
  }

  Future<void> clear() async {
    await _repository.clear();
    load();
  }
}
