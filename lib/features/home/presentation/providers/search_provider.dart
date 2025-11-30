import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/home/presentation/constants/search_constants.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

part 'search_provider.g.dart';

class SearchFilter {
  final String query;
  final RangeValues priceRange;
  final bool isFilterActive;
  final String? selectedCategory;
  final List<String> vibes;
  final List<String> architectures;

  const SearchFilter({
    this.query = '',
    this.priceRange = SearchConstants.defaultPriceRange,
    this.isFilterActive = false,
    this.selectedCategory,
    this.vibes = const [],
    this.architectures = const [],
  });

  SearchFilter copyWith({
    String? query,
    RangeValues? priceRange,
    bool? isFilterActive,
    String? selectedCategory,
    List<String>? vibes,
    List<String>? architectures,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      priceRange: priceRange ?? this.priceRange,
      isFilterActive: isFilterActive ?? this.isFilterActive,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      vibes: vibes ?? this.vibes,
      architectures: architectures ?? this.architectures,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilter &&
        other.query == query &&
        other.priceRange == priceRange &&
        other.isFilterActive == isFilterActive &&
        other.selectedCategory == selectedCategory &&
        listEquals(other.vibes, vibes) &&
        listEquals(other.architectures, architectures);
  }

  @override
  int get hashCode =>
      query.hashCode ^
      priceRange.hashCode ^
      isFilterActive.hashCode ^
      selectedCategory.hashCode ^
      vibes.hashCode ^
      architectures.hashCode;
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

@Riverpod(keepAlive: false)
class SearchFilterState extends _$SearchFilterState {
  @override
  SearchFilter build() {
    return const SearchFilter();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, isFilterActive: true);
  }

  void setPriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range, isFilterActive: true);
  }

  void setVibes(List<String> vibes) {
    state = state.copyWith(vibes: vibes, isFilterActive: true);
  }

  void setArchitectures(List<String> architectures) {
    state = state.copyWith(architectures: architectures, isFilterActive: true);
  }

  void setCategory(String? categoryId) {
    final isDefaultPrice = state.priceRange == SearchConstants.defaultPriceRange;
    final isDefaultQuery = state.query.isEmpty;
    final isDefaultCategory = categoryId == null;
    final isDefaultVibes = state.vibes.isEmpty;
    final isDefaultArchitectures = state.architectures.isEmpty;

    state = SearchFilter(
      query: state.query,
      priceRange: state.priceRange,
      isFilterActive: !(isDefaultPrice && isDefaultQuery && isDefaultCategory && isDefaultVibes && isDefaultArchitectures),
      selectedCategory: categoryId,
      vibes: state.vibes,
      architectures: state.architectures,
    );
  }

  void reset() {
    state = const SearchFilter();
  }
}

@riverpod
Future<List<Property>> filteredProperties(FilteredPropertiesRef ref) async {
  final allProperties = await ref.watch(allPropertiesProvider.future);
  final filter = ref.watch(searchFilterStateProvider);

  if (!filter.isFilterActive &&
      filter.query.isEmpty &&
      filter.selectedCategory == null &&
      filter.vibes.isEmpty &&
      filter.architectures.isEmpty) {
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
    
    if (!matchesPrice) {
       // print('Price mismatch for ${property.name}: ${property.pricePerNight} not in ${filter.priceRange}');
    }

    bool matchesCategory = true;
    if (filter.selectedCategory != null && filter.selectedCategory!.isNotEmpty) {
      matchesCategory = property.categoryId == filter.selectedCategory;
    }

    bool matchesVibe = true;
    if (filter.vibes.isNotEmpty) {
      matchesVibe = filter.vibes.contains(property.vibe);
    }

    bool matchesArchitecture = true;
    if (filter.architectures.isNotEmpty) {
      matchesArchitecture = filter.architectures.contains(property.architectureStyle);
    }

    return matchesQuery && matchesPrice && matchesCategory && matchesVibe && matchesArchitecture;
  }).toList();
}
