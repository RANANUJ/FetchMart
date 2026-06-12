import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../routes/app_router.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../providers/wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(
      wishlistControllerProvider.select((state) => state.products),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: products.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved products yet',
              message: 'Tap the heart icon on a product to save it here.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      key: ValueKey<int>(product.id),
                      product: product,
                      onTap: () => Navigator.of(
                        context,
                      ).push(AppRouter.productDetail(product)),
                    );
                  },
                );
              },
            ),
    );
  }
}
