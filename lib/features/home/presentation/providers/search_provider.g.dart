// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredPropertiesHash() =>
    r'db6ba2837fdf2a8e21bc37f3d67f78c8d0ce0a85';

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
String _$searchFilterStateHash() => r'1783c212281963c0d902ab09966779c5271ecaf0';

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
