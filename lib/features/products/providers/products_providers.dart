import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/dependency_providers.dart';
import 'product_catalog_controller.dart';
import 'product_catalog_state.dart';
import 'search_history_controller.dart';

final productCatalogControllerProvider =
    StateNotifierProvider<ProductCatalogController, ProductCatalogState>((ref) {
      return ProductCatalogController(
        getProducts: ref.watch(getProductsProvider),
        getProductCategories: ref.watch(getProductCategoriesProvider),
      );
    });

final searchHistoryControllerProvider =
    StateNotifierProvider<SearchHistoryController, List<String>>(
      (ref) => SearchHistoryController(ref.watch(recentSearchesBoxProvider)),
    );
