import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/product.dart';
import '../domain/usecases/get_product_categories.dart';
import '../domain/usecases/get_products.dart';
import 'product_catalog_state.dart';

class ProductCatalogController extends StateNotifier<ProductCatalogState> {
  ProductCatalogController({
    required GetProducts getProducts,
    required GetProductCategories getProductCategories,
  }) : _getProducts = getProducts,
       _getProductCategories = getProductCategories,
       super(const ProductCatalogState(isInitialLoading: true)) {
    loadCategories();
    loadInitial();
  }

  final GetProducts _getProducts;
  final GetProductCategories _getProductCategories;

  Future<void> loadCategories() async {
    try {
      final categories = await _getProductCategories();
      if (!mounted) return;
      state = state.copyWith(categories: categories);
    } on ApiException catch (error) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: error.message);
    }
  }

  Future<void> loadInitial({bool refreshing = false}) async {
    if (state.isInitialLoading && !refreshing && state.products.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      isInitialLoading: !refreshing,
      isRefreshing: refreshing,
      isLoadingMore: false,
      hasReachedEnd: false,
      errorMessage: null,
      paginationError: null,
      isFromCache: false,
    );

    try {
      final page = await _getProducts(
        limit: ApiConstants.defaultPageSize,
        skip: 0,
        categorySlug: state.selectedCategorySlug,
      );
      if (!mounted) return;

      state = state.copyWith(
        products: page.products,
        total: page.total,
        isInitialLoading: false,
        isRefreshing: false,
        isFromCache: page.isFromCache,
        hasReachedEnd:
            page.isFromCache ||
            page.products.length >= page.total ||
            page.products.length < ApiConstants.defaultPageSize,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        products: const [],
        isInitialLoading: false,
        isRefreshing: false,
        errorMessage: error.message,
      );
    }
  }

  Future<void> refresh() => loadInitial(refreshing: true);

  Future<void> loadMore() async {
    if (state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        state.hasReachedEnd ||
        state.isFromCache) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, paginationError: null);

    try {
      final page = await _getProducts(
        limit: ApiConstants.defaultPageSize,
        skip: state.products.length,
        categorySlug: state.selectedCategorySlug,
      );
      if (!mounted) return;

      final merged = <int, Product>{
        for (final product in state.products) product.id: product,
        for (final product in page.products) product.id: product,
      }.values.toList(growable: false);

      state = state.copyWith(
        products: merged,
        total: page.total,
        isLoadingMore: false,
        hasReachedEnd:
            merged.length >= page.total ||
            page.products.length < ApiConstants.defaultPageSize,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        paginationError: error.message,
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> selectCategory(String? categorySlug) async {
    if (state.selectedCategorySlug == categorySlug) return;

    await applyFilters(categorySlug: categorySlug);
  }

  Future<void> applyFilters({
    String? categorySlug,
    double? minPrice,
    double? maxPrice,
    ProductSortOption? sortOption,
  }) async {
    final categoryChanged = state.selectedCategorySlug != categorySlug;
    state = state.copyWith(
      products: categoryChanged ? const [] : state.products,
      selectedCategorySlug: categorySlug,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortOption: sortOption,
    );
    if (categoryChanged) {
      await loadInitial();
    }
  }

  void applyPriceRange({double? minPrice, double? maxPrice}) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateSortOption(ProductSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  Future<void> clearFilters() async {
    final hadCategory = state.selectedCategorySlug != null;
    state = state.copyWith(
      selectedCategorySlug: null,
      minPrice: null,
      maxPrice: null,
      sortOption: ProductSortOption.popular,
    );
    if (hadCategory) {
      await loadInitial();
    }
  }
}
