import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/dependency_providers.dart';
import '../data/datasources/cart_local_data_source.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/repositories/cart_repository.dart';
import 'cart_controller.dart';
import 'cart_state.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>(
  (ref) => CartLocalDataSource(ref.watch(cartBoxProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(ref.watch(cartLocalDataSourceProvider)),
);

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(ref.watch(cartRepositoryProvider)),
);
