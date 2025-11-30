import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/home/presentation/constants/search_constants.dart';
import 'package:villavibe/features/home/presentation/providers/search_provider.dart';

class SearchFilterModal extends ConsumerStatefulWidget {
  const SearchFilterModal({super.key});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  late RangeValues _currentRangeValues;
  final List<String> _selectedVibes = [];
  final List<String> _selectedArchitectures = [];

  @override
  void initState() {
    super.initState();
    final filterState = ref.read(searchFilterStateProvider);

    // Ensure range values are within bounds
    double start = filterState.priceRange.start.clamp(
        SearchConstants.minPrice, SearchConstants.maxPrice);
    double end = filterState.priceRange.end.clamp(
        SearchConstants.minPrice, SearchConstants.maxPrice);
    if (end == 0 && start == 0) {
      end = SearchConstants.maxPrice; // Handle initial default case if needed
    }

    _currentRangeValues = RangeValues(start, end);
    _selectedVibes.addAll(filterState.vibes);
    _selectedArchitectures.addAll(filterState.architectures);
  }

  void _applyFilters() {
    final notifier = ref.read(searchFilterStateProvider.notifier);
    notifier.setPriceRange(_currentRangeValues);
    notifier.setVibes(_selectedVibes);
    notifier.setArchitectures(_selectedArchitectures);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _currentRangeValues = SearchConstants.defaultPriceRange;
    });
    // We don't want to reset the query here, only the filters in the modal
    // So we manually set price range instead of calling reset() which clears everything
    ref
        .read(searchFilterStateProvider.notifier)
        .setPriceRange(SearchConstants.defaultPriceRange);
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
            min: SearchConstants.minPrice,
            max: SearchConstants.maxPrice,
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

          const SizedBox(height: 24),

          // Vibe Filter
          const Text(
            'Vibe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Zen',
              'Party',
              'Romantic',
              'Family',
              'Work'
            ].map((vibe) {
              final isSelected = _selectedVibes.contains(vibe);
              return FilterChip(
                label: Text(vibe),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedVibes.add(vibe);
                    } else {
                      _selectedVibes.remove(vibe);
                    }
                  });
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Architecture Filter
          const Text(
            'Architecture',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Modern',
              'Joglo',
              'Bamboo',
              'Tropical',
              'Industrial'
            ].map((style) {
              final isSelected = _selectedArchitectures.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedArchitectures.add(style);
                    } else {
                      _selectedArchitectures.remove(style);
                    }
                  });
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
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
