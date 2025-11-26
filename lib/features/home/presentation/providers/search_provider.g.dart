// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredPropertiesHash() =>
    r'fe797ef930b41c23cbafc6371a47e5d5f4fe1753';

/// See also [filteredProperties].
@ProviderFor(filteredProperties)
final filteredPropertiesProvider =
    AutoDisposeFutureProvider<List<Property>>.internal(
  filteredProperties,
  name: r'filteredPropertiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredPropertiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredPropertiesRef = AutoDisposeFutureProviderRef<List<Property>>;
String _$searchFilterStateHash() => r'e962e6a4d433ce11e5bad7b6904f75ed9bd69017';

/// See also [SearchFilterState].
@ProviderFor(SearchFilterState)
final searchFilterStateProvider =
    AutoDisposeNotifierProvider<SearchFilterState, SearchFilter>.internal(
  SearchFilterState.new,
  name: r'searchFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchFilterState = AutoDisposeNotifier<SearchFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
