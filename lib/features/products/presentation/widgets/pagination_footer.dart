import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    required this.isLoading,
    required this.hasReachedEnd,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final bool isLoading;
  final bool hasReachedEnd;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: _DotsLoader()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Load more'),
        ),
      );
    }

    if (hasReachedEnd) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Text(
          'You have reached the end',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = ((_controller.value + index / 3) % 1.0);
            final size = 6 + (value < 0.5 ? value : 1 - value) * 8;
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );
          }),
        );
      },
    );
  }
}
