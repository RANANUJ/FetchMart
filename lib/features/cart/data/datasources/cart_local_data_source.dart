import 'package:hive/hive.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../models/cart_item_model.dart';

class CartLocalDataSource {
  const CartLocalDataSource(this._box);

  final Box<dynamic> _box;

  List<CartItemModel> getAll() {
    return _box.values
        .whereType<Map>()
        .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> add(Product product) async {
    final existing = _readItem(product.id);
    final quantity = existing == null
        ? 1
        : (existing.quantity + 1).clamp(1, 99).toInt();
    await _box.put(
      product.id,
      CartItemModel(
        product: ProductModel.fromEntity(product),
        quantity: quantity,
      ).toJson(),
    );
  }

  Future<void> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    final existing = _readItem(productId);
    if (existing == null) return;

    if (quantity <= 0) {
      await remove(productId);
      return;
    }

    await _box.put(
      productId,
      CartItemModel(
        product: ProductModel.fromEntity(existing.product),
        quantity: quantity.clamp(1, 99).toInt(),
      ).toJson(),
    );
  }

  Future<void> remove(int productId) => _box.delete(productId);

  Future<void> clear() => _box.clear();

  CartItemModel? _readItem(int productId) {
    final raw = _box.get(productId);
    if (raw is! Map) return null;
    return CartItemModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
