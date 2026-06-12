import 'dart:math' as math;

import '../domain/entities/product.dart';
import '../domain/entities/product_category.dart';

const Object _unset = Object();

enum ProductSortOption {
  popular,
  newest,
  priceLowToHigh,
  priceHighToLow,
  rating,
}

extension ProductSortOptionLabel on ProductSortOption {
  String get label {
    return switch (this) {
      ProductSortOption.popular => 'Popular',
      ProductSortOption.newest => 'Newest',
      ProductSortOption.priceLowToHigh => 'Price: Low to High',
      ProductSortOption.priceHighToLow => 'Price: High to Low',
      ProductSortOption.rating => 'Top Rated',
    };
  }
}

class ProductCatalogState {
  const ProductCatalogState({
    this.products = const <Product>[],
    this.categories = const <ProductCategory>[],
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isFromCache = false,
    this.total = 0,
    this.searchQuery = '',
    this.selectedCategorySlug,
    this.minPrice,
    this.maxPrice,
    this.sortOption = ProductSortOption.popular,
    this.errorMessage,
    this.paginationError,
  });

  final List<Product> products;
  final List<ProductCategory> categories;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool isFromCache;
  final int total;
  final String searchQuery;
  final String? selectedCategorySlug;
  final double? minPrice;
  final double? maxPrice;
  final ProductSortOption sortOption;
  final String? errorMessage;
  final String? paginationError;

  List<Product> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();
    final filtered = products.where((product) {
      final matchesQuery =
          query.isEmpty || product.title.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategorySlug == null ||
          product.category == selectedCategorySlug;
      final matchesMinimum = minPrice == null || product.price >= minPrice!;
      final matchesMaximum = maxPrice == null || product.price <= maxPrice!;

      return matchesQuery &&
          matchesCategory &&
          matchesMinimum &&
          matchesMaximum;
    });

    final visibleProducts = filtered.toList(growable: false);
    if (sortOption == ProductSortOption.popular) {
      return visibleProducts;
    }

    visibleProducts.sort(_compareProducts);
    return visibleProducts;
  }

  bool get hasActiveFilters =>
      selectedCategorySlug != null || minPrice != null || maxPrice != null;

  bool get hasActiveSort => sortOption != ProductSortOption.popular;

  bool get hasActiveControls => hasActiveFilters || hasActiveSort;

  double get availableMinPrice {
    if (products.isEmpty) return 0;
    return products.map((product) => product.price).reduce(math.min);
  }

  double get availableMaxPrice {
    if (products.isEmpty) return 1000;
    final maxPrice = products.map((product) => product.price).reduce(math.max);
    return maxPrice <= availableMinPrice ? availableMinPrice + 1 : maxPrice;
  }

  ProductCategory? get selectedCategory {
    for (final category in categories) {
      if (category.slug == selectedCategorySlug) return category;
    }
    return null;
  }

  ProductCatalogState copyWith({
    List<Product>? products,
    List<ProductCategory>? categories,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isFromCache,
    int? total,
    String? searchQuery,
    Object? selectedCategorySlug = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    ProductSortOption? sortOption,
    Object? errorMessage = _unset,
    Object? paginationError = _unset,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isFromCache: isFromCache ?? this.isFromCache,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategorySlug: selectedCategorySlug == _unset
          ? this.selectedCategorySlug
          : selectedCategorySlug as String?,
      minPrice: minPrice == _unset ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _unset ? this.maxPrice : maxPrice as double?,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      paginationError: paginationError == _unset
          ? this.paginationError
          : paginationError as String?,
    );
  }

  int _compareProducts(Product first, Product second) {
    final comparison = switch (sortOption) {
      ProductSortOption.popular => 0,
      ProductSortOption.newest => second.id.compareTo(first.id),
      ProductSortOption.priceLowToHigh => first.price.compareTo(second.price),
      ProductSortOption.priceHighToLow => second.price.compareTo(first.price),
      ProductSortOption.rating => second.rating.compareTo(first.rating),
    };

    if (comparison != 0) return comparison;
    return first.id.compareTo(second.id);
  }
}
