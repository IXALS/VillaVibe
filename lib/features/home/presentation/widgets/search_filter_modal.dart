import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/home/presentation/providers/search_provider.dart';

class SearchFilterModal extends ConsumerStatefulWidget {
  const SearchFilterModal({super.key});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  late RangeValues _currentRangeValues;

  // Define min and max price constants
  static const double _minPrice = 0;
  static const double _maxPrice = 3000;

  @override
  void initState() {
    super.initState();
    final filterState = ref.read(searchFilterStateProvider);

    // Ensure range values are within bounds
    double start = filterState.priceRange.start.clamp(_minPrice, _maxPrice);
    double end = filterState.priceRange.end.clamp(_minPrice, _maxPrice);
    if (end == 0 && start == 0) {
      end = _maxPrice; // Handle initial default case if needed
    }

    _currentRangeValues = RangeValues(start, end);
  }

  void _applyFilters() {
    ref
        .read(searchFilterStateProvider.notifier)
        .setPriceRange(_currentRangeValues);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _currentRangeValues = const RangeValues(_minPrice, _maxPrice);
    });
    // We don't want to reset the query here, only the filters in the modal
    // So we manually set price range instead of calling reset() which clears everything
    ref
        .read(searchFilterStateProvider.notifier)
        .setPriceRange(const RangeValues(_minPrice, _maxPrice));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price Range
          const Text(
            'Price Range (per night)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _currentRangeValues,
            min: _minPrice,
            max: _maxPrice,
            divisions: 20,
            labels: RangeLabels(
              '\$${_currentRangeValues.start.round()}',
              '\$${_currentRangeValues.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_currentRangeValues.start.round()}'),
              Text('\$${_currentRangeValues.end.round()}'),
            ],
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Show Results',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
