import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/connectivity_service.dart';
import '../features/products/data/datasources/products_local_data_source.dart';
import '../features/products/data/datasources/products_remote_data_source.dart';
import '../features/products/data/repositories/products_repository_impl.dart';
import '../features/products/domain/repositories/products_repository.dart';
import '../features/products/domain/usecases/get_product_categories.dart';
import '../features/products/domain/usecases/get_products.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final productsCacheBoxProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(AppConstants.productsCacheBox),
);

final wishlistBoxProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(AppConstants.wishlistBox),
);

final recentSearchesBoxProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(AppConstants.recentSearchesBox),
);

final cartBoxProvider = Provider<Box<dynamic>>(
  (ref) => Hive.box<dynamic>(AppConstants.cartBox),
);

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>(
  (ref) => ProductsRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final productsLocalDataSourceProvider = Provider<ProductsLocalDataSource>(
  (ref) => ProductsLocalDataSource(ref.watch(productsCacheBoxProvider)),
);

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    remoteDataSource: ref.watch(productsRemoteDataSourceProvider),
    localDataSource: ref.watch(productsLocalDataSourceProvider),
  );
});

final getProductsProvider = Provider<GetProducts>(
  (ref) => GetProducts(ref.watch(productsRepositoryProvider)),
);

final getProductCategoriesProvider = Provider<GetProductCategories>(
  (ref) => GetProductCategories(ref.watch(productsRepositoryProvider)),
);
