import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../routes/app_router.dart';
import '../../../cart/providers/cart_providers.dart';
import '../../../wishlist/providers/wishlist_providers.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(
      wishlistControllerProvider.select((state) => state.contains(product.id)),
    );
    final cartQuantity = ref.watch(
      cartControllerProvider.select((state) => state.quantityFor(product.id)),
    );
    final imageUrls = _productImageUrls(product);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: _ProductImageCarousel(imageUrls: imageUrls),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RatingPill(rating: product.rating),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  Formatters.currency(product.price),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.category_rounded,
                      label: Formatters.categoryName(product.category),
                    ),
                    _InfoChip(
                      icon: Icons.inventory_2_rounded,
                      label: product.stock > 0
                          ? '${product.stock} in stock'
                          : 'Out of stock',
                    ),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.verified_rounded,
                        label: product.brand!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ref
                    .read(wishlistControllerProvider.notifier)
                    .toggle(product),
                icon: Icon(
                  isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                label: Text(isWishlisted ? 'Saved' : 'Wishlist'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(cartControllerProvider.notifier).add(product);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.title} added to cart'),
                      action: SnackBarAction(
                        label: 'View',
                        onPressed: () =>
                            Navigator.of(context).push(AppRouter.cart()),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  cartQuantity > 0
                      ? 'Add another ($cartQuantity)'
                      : 'Add to cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _productImageUrls(Product product) {
  final uniqueUrls = <String>{};
  for (final url in [...product.images, product.thumbnail]) {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isNotEmpty) {
      uniqueUrls.add(normalizedUrl);
    }
  }

  return uniqueUrls.toList(growable: false);
}

class _ProductImageCarousel extends StatefulWidget {
  const _ProductImageCarousel({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_rounded),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) => _currentIndex.value = index,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const ShimmerBox(
                width: double.infinity,
                height: double.infinity,
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_rounded),
              ),
            );
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x99000000)],
            ),
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          Positioned(
            left: 16,
            right: 16,
            bottom: 78,
            child: _CarouselDots(
              currentIndex: _currentIndex,
              itemCount: widget.imageUrls.length,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _CarouselThumbnails(
              imageUrls: widget.imageUrls,
              currentIndex: _currentIndex,
              onSelected: _animateToPage,
            ),
          ),
        ],
      ],
    );
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.currentIndex, required this.itemCount});

  final ValueNotifier<int> currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, selectedIndex, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (index) {
            final isSelected = index == selectedIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 18 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white70,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CarouselThumbnails extends StatelessWidget {
  const _CarouselThumbnails({
    required this.imageUrls,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<String> imageUrls;
  final ValueNotifier<int> currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ValueListenableBuilder<int>(
        valueListenable: currentIndex,
        builder: (context, selectedIndex, child) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.white,
    );
  }
}
