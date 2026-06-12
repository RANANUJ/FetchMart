import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  @override
  List<CartItem> getAll() => _localDataSource.getAll();

  @override
  Future<void> add(Product product) => _localDataSource.add(product);

  @override
  Future<void> clear() => _localDataSource.clear();

  @override
  Future<void> remove(int productId) => _localDataSource.remove(productId);

  @override
  Future<void> updateQuantity({required int productId, required int quantity}) {
    return _localDataSource.updateQuantity(
      productId: productId,
      quantity: quantity,
    );
  }
}
