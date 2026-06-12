import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../providers/product_catalog_state.dart';
import '../../providers/products_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? _categorySlug;
  late RangeValues _range;
  late bool _usePriceRange;
  late ProductSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    final state = ref.read(productCatalogControllerProvider);
    _categorySlug = state.selectedCategorySlug;
    _usePriceRange = state.minPrice != null || state.maxPrice != null;
    _sortOption = state.sortOption;
    _range = RangeValues(
      state.minPrice ?? state.availableMinPrice,
      state.maxPrice ?? state.availableMaxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productCatalogControllerProvider);
    final minBound = state.availableMinPrice.floorToDouble();
    final maxBound = state.availableMaxPrice.ceilToDouble();
    final safeRange = RangeValues(
      _range.start.clamp(minBound, maxBound).toDouble(),
      _range.end.clamp(minBound, maxBound).toDouble(),
    );

    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ProductSortOption.values)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: _sortOption == option,
                      onSelected: (_) => setState(() => _sortOption = option),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _categorySlug == null,
                    onSelected: (_) => setState(() => _categorySlug = null),
                  ),
                  for (final category in state.categories)
                    ChoiceChip(
                      label: Text(category.name),
                      selected: _categorySlug == category.slug,
                      onSelected: (_) =>
                          setState(() => _categorySlug = category.slug),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _usePriceRange,
                title: const Text('Price range'),
                subtitle: Text(
                  '${Formatters.compactCurrency(safeRange.start)} - '
                  '${Formatters.compactCurrency(safeRange.end)}',
                ),
                onChanged: (value) => setState(() => _usePriceRange = value),
              ),
              RangeSlider(
                values: safeRange,
                min: minBound,
                max: maxBound,
                divisions: (maxBound - minBound).round().clamp(1, 100),
                labels: RangeLabels(
                  Formatters.compactCurrency(safeRange.start),
                  Formatters.compactCurrency(safeRange.end),
                ),
                onChanged: _usePriceRange
                    ? (value) => setState(() => _range = value)
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(productCatalogControllerProvider.notifier)
                            .clearFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(productCatalogControllerProvider.notifier)
                            .applyFilters(
                              categorySlug: _categorySlug,
                              minPrice: _usePriceRange ? safeRange.start : null,
                              maxPrice: _usePriceRange ? safeRange.end : null,
                              sortOption: _sortOption,
                            );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
