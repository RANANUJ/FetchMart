import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../routes/app_router.dart';
import '../../../cart/providers/cart_providers.dart';
import '../../../wishlist/providers/wishlist_providers.dart';
import '../../domain/entities/product.dart';
import '../../providers/product_catalog_state.dart';
import '../../providers/products_providers.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_skeleton.dart';
import '../widgets/product_search_field.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  static const double _loadMoreExtentThreshold = 1200;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _showSuggestions = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();
  final _debouncer = Debouncer();
  double _lastCatalogOffset = 0;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchFocusNode
      ..removeListener(_handleSearchFocusChange)
      ..dispose();
    _showSuggestions.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _lastCatalogOffset = _scrollController.offset;
    if (_scrollController.position.extentAfter < _loadMoreExtentThreshold) {
      ref.read(productCatalogControllerProvider.notifier).loadMore();
    }
  }

  void _handleSearchFocusChange() {
    _showSuggestions.value = _searchFocusNode.hasFocus;
  }

  void _submitSearch(String query) {
    final normalized = query.trim();
    _debouncer.cancel();
    ref
        .read(productCatalogControllerProvider.notifier)
        .updateSearchQuery(normalized);
    ref.read(searchHistoryControllerProvider.notifier).add(normalized);
    _searchFocusNode.unfocus();
  }

  void _selectSuggestion(String suggestion) {
    _searchController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    _submitSearch(suggestion);
  }

  Future<void> _openProduct(Product product) async {
    if (_scrollController.hasClients) {
      _lastCatalogOffset = _scrollController.offset;
    }
    _searchFocusNode.unfocus();
    _showSuggestions.value = false;

    await Navigator.of(context).push(AppRouter.productDetail(product));
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final targetOffset = _lastCatalogOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      if ((_scrollController.offset - targetOffset).abs() > 1) {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productCatalogControllerProvider);
    final visibleProducts = state.visibleProducts;
    final visibleProductIndexById = <int, int>{
      for (final entry in visibleProducts.asMap().entries)
        entry.value.id: entry.key,
    };
    final cartQuantity = ref.watch(
      cartControllerProvider.select((state) => state.totalQuantity),
    );
    final wishlistCount = ref.watch(
      wishlistControllerProvider.select((state) => state.products.length),
    );

    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => Navigator.of(context).push(AppRouter.cart()),
            icon: Badge(
              isLabelVisible: cartQuantity > 0,
              label: Text(cartQuantity.toString()),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () => Navigator.of(context).push(AppRouter.wishlist()),
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text(wishlistCount.toString()),
              child: const Icon(Icons.favorite_border_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productCatalogControllerProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _crossAxisCount(constraints.maxWidth);

            return CustomScrollView(
              key: const PageStorageKey<String>('products-catalog-scroll-view'),
              controller: _scrollController,
              cacheExtent: 900,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _catalogHeader(state: state)),
                if (state.isInitialLoading)
                  ProductGridSkeleton(crossAxisCount: crossAxisCount)
                else if (state.errorMessage != null && state.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorView(
                      title: 'Could not load products',
                      message: state.errorMessage!,
                      onRetry: () => ref
                          .read(productCatalogControllerProvider.notifier)
                          .loadInitial(),
                    ),
                  )
                else if (visibleProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: state.searchQuery.isEmpty
                          ? 'No products found'
                          : 'No matching products',
                      message:
                          'Try a different search term or adjust your filters.',
                      action: state.hasActiveFilters
                          ? OutlinedButton.icon(
                              onPressed: () => ref
                                  .read(
                                    productCatalogControllerProvider.notifier,
                                  )
                                  .clearFilters(),
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text('Clear filters'),
                            )
                          : null,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverGrid.builder(
                      itemCount: visibleProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      findChildIndexCallback: (key) {
                        if (key is ValueKey<int>) {
                          return visibleProductIndexById[key.value];
                        }
                        return null;
                      },
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];
                        return ProductCard(
                          key: ValueKey<int>(product.id),
                          product: product,
                          onTap: () => _openProduct(product),
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(
                  child: PaginationFooter(
                    isLoading: state.isLoadingMore,
                    hasReachedEnd:
                        state.hasReachedEnd && visibleProducts.isNotEmpty,
                    errorMessage: state.paginationError,
                    onRetry: () => ref
                        .read(productCatalogControllerProvider.notifier)
                        .loadMore(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _catalogHeader({required ProductCatalogState state}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) => _debouncer.run(
              () => ref
                  .read(productCatalogControllerProvider.notifier)
                  .updateSearchQuery(value),
            ),
            onSubmitted: _submitSearch,
            onClear: () {
              _debouncer.cancel();
              _searchController.clear();
              ref
                  .read(productCatalogControllerProvider.notifier)
                  .updateSearchQuery('');
              _searchFocusNode.requestFocus();
            },
          ),
          _SearchSuggestionsHost(
            controller: _searchController,
            visibleListenable: _showSuggestions,
            state: state,
            recentSearches: ref.watch(searchHistoryControllerProvider),
            onSelected: _selectSuggestion,
            onRemoveRecent: (query) => ref
                .read(searchHistoryControllerProvider.notifier)
                .remove(query),
            onClearRecent: () =>
                ref.read(searchHistoryControllerProvider.notifier).clear(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _CategoryStrip(state: state)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Open filters',
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: false,
                  builder: (_) => const FilterBottomSheet(),
                ),
                icon: Badge(
                  isLabelVisible: state.hasActiveControls,
                  child: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
          if (state.isFromCache) ...[
            const SizedBox(height: 12),
            _CacheBanner(total: state.products.length),
          ],
        ],
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width >= 1050) return 5;
    if (width >= 820) return 4;
    if (width >= 560) return 3;
    return 2;
  }
}

class _SearchSuggestionsHost extends StatelessWidget {
  const _SearchSuggestionsHost({
    required this.controller,
    required this.visibleListenable,
    required this.state,
    required this.recentSearches,
    required this.onSelected,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> visibleListenable;
  final ProductCatalogState state;
  final List<String> recentSearches;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibleListenable,
      builder: (context, isVisible, child) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final query = value.text.trim();
            final suggestions = _buildSuggestions(query);
            final shouldShow = isVisible && suggestions.isNotEmpty;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: shouldShow
                  ? _SearchSuggestionsPanel(
                      key: ValueKey(query),
                      title: query.isEmpty
                          ? 'Recent searches'
                          : 'Search suggestions',
                      suggestions: suggestions,
                      recentSearches: recentSearches,
                      onSelected: onSelected,
                      onRemoveRecent: onRemoveRecent,
                      onClearRecent: onClearRecent,
                    )
                  : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  List<String> _buildSuggestions(String query) {
    final normalizedQuery = query.toLowerCase();
    final suggestions = <String>[];

    void addUnique(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      final exists = suggestions.any(
        (item) => item.toLowerCase() == trimmed.toLowerCase(),
      );
      if (!exists) suggestions.add(trimmed);
    }

    if (normalizedQuery.isEmpty) {
      for (final item in recentSearches) {
        addUnique(item);
      }
      return suggestions.take(6).toList(growable: false);
    }

    for (final item in recentSearches) {
      if (item.toLowerCase().contains(normalizedQuery)) {
        addUnique(item);
      }
    }

    for (final product in state.products) {
      if (product.title.toLowerCase().contains(normalizedQuery)) {
        addUnique(product.title);
      }
    }

    return suggestions.take(6).toList(growable: false);
  }
}

class _SearchSuggestionsPanel extends StatelessWidget {
  const _SearchSuggestionsPanel({
    required super.key,
    required this.title,
    required this.suggestions,
    required this.recentSearches,
    required this.onSelected,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });

  final String title;
  final List<String> suggestions;
  final List<String> recentSearches;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final recentSet = recentSearches.map((item) => item.toLowerCase()).toSet();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (title == 'Recent searches')
                      TextButton(
                        onPressed: onClearRecent,
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              for (final suggestion in suggestions)
                ListTile(
                  dense: true,
                  leading: Icon(
                    recentSet.contains(suggestion.toLowerCase())
                        ? Icons.history_rounded
                        : Icons.search_rounded,
                  ),
                  title: Text(
                    suggestion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: recentSet.contains(suggestion.toLowerCase())
                      ? IconButton(
                          tooltip: 'Remove recent search',
                          onPressed: () => onRemoveRecent(suggestion),
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  onTap: () => onSelected(suggestion),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FetchMart',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(
          'Curated products',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip({required this.state});

  final ProductCatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('All'),
              selected: state.selectedCategorySlug == null,
              onSelected: (_) => ref
                  .read(productCatalogControllerProvider.notifier)
                  .selectCategory(null),
            );
          }

          final category = state.categories[index - 1];
          return ChoiceChip(
            label: Text(category.name),
            selected: state.selectedCategorySlug == category.slug,
            onSelected: (_) => ref
                .read(productCatalogControllerProvider.notifier)
                .selectCategory(category.slug),
          );
        },
      ),
    );
  }
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_rounded, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing $total saved products while offline',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
