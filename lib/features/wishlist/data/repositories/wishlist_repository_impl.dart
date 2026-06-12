import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  const WishlistRepositoryImpl(this._localDataSource);

  final WishlistLocalDataSource _localDataSource;

  @override
  List<Product> getAll() => _localDataSource.getAll();

  @override
  Future<void> add(Product product) {
    return _localDataSource.add(ProductModel.fromEntity(product));
  }

  @override
  bool contains(int productId) => _localDataSource.contains(productId);

  @override
  Future<void> remove(int productId) => _localDataSource.remove(productId);
}
