import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/dependency_providers.dart';
import '../data/datasources/wishlist_local_data_source.dart';
import '../data/repositories/wishlist_repository_impl.dart';
import '../domain/repositories/wishlist_repository.dart';
import 'wishlist_controller.dart';
import 'wishlist_state.dart';

final wishlistLocalDataSourceProvider = Provider<WishlistLocalDataSource>(
  (ref) => WishlistLocalDataSource(ref.watch(wishlistBoxProvider)),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepositoryImpl(ref.watch(wishlistLocalDataSourceProvider)),
);

final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, WishlistState>(
      (ref) => WishlistController(ref.watch(wishlistRepositoryProvider)),
    );
