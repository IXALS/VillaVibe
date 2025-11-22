import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

part 'search_provider.g.dart';

class SearchFilter {
  final String query;
  final RangeValues priceRange;
  final bool isFilterActive;

  const SearchFilter({
    this.query = '',
    this.priceRange =
        const RangeValues(0, 10000), // Default max price high enough
    this.isFilterActive = false,
  });

  SearchFilter copyWith({
    String? query,
    RangeValues? priceRange,
    bool? isFilterActive,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      priceRange: priceRange ?? this.priceRange,
      isFilterActive: isFilterActive ?? this.isFilterActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilter &&
        other.query == query &&
        other.priceRange == priceRange &&
        other.isFilterActive == isFilterActive;
  }

  @override
  int get hashCode =>
      query.hashCode ^ priceRange.hashCode ^ isFilterActive.hashCode;
}

@Riverpod(keepAlive: true)
class SearchFilterState extends _$SearchFilterState {
  @override
  SearchFilter build() {
    print('SearchFilterState: build called (init/reset)');
    return const SearchFilter();
  }

  void setQuery(String query) {

    state = state.copyWith(query: query, isFilterActive: true);
  }

  void setPriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range, isFilterActive: true);
  }

  void reset() {
    state = const SearchFilter();
  }
}

@riverpod
Future<List<Property>> filteredProperties(FilteredPropertiesRef ref) async {
  final allProperties = await ref.watch(allPropertiesProvider.future);
  final filter = ref.watch(searchFilterStateProvider);

  

  if (!filter.isFilterActive && filter.query.isEmpty) {
    return allProperties;
  }

  return allProperties.where((property) {
    // Case insensitive search
    final query = filter.query.toLowerCase().trim();

    bool matchesQuery = true;
    if (query.isNotEmpty) {
      matchesQuery = property.name.toLowerCase().contains(query) ||
          property.city.toLowerCase().contains(query);
    }

    final matchesPrice = property.pricePerNight >= filter.priceRange.start &&
        property.pricePerNight <= filter.priceRange.end;

    return matchesQuery && matchesPrice;
  }).toList();
}
