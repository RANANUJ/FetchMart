import '../../../products/domain/entities/product.dart';
import '../entities/cart_item.dart';

abstract interface class CartRepository {
  List<CartItem> getAll();

  Future<void> add(Product product);

  Future<void> updateQuantity({required int productId, required int quantity});

  Future<void> remove(int productId);

  Future<void> clear();
}
