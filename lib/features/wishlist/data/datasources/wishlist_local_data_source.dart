import 'package:hive/hive.dart';

import '../../../products/data/models/product_model.dart';

class WishlistLocalDataSource {
  const WishlistLocalDataSource(this._box);

  final Box<dynamic> _box;

  List<ProductModel> getAll() {
    return _box.values
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> add(ProductModel product) {
    return _box.put(product.id, product.toJson());
  }

  Future<void> remove(int productId) {
    return _box.delete(productId);
  }

  bool contains(int productId) {
    return _box.containsKey(productId);
  }
}
