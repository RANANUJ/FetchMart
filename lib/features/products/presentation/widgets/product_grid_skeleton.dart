import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_box.dart';

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({required this.crossAxisCount, super.key});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid.builder(
        itemCount: crossAxisCount * 3,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                SizedBox(height: 12),
                ShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 96, height: 14),
                SizedBox(height: 12),
                Row(
                  children: [
                    ShimmerBox(width: 72, height: 18),
                    Spacer(),
                    ShimmerBox(width: 52, height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
