// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredPropertiesHash() =>
    r'61af34e2f79b949d3a80cbda2061d78bdb4049c6';

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
String _$searchFilterStateHash() => r'db0313076ea8a269170f7af4e535197085e9d394';

/// See also [SearchFilterState].
@ProviderFor(SearchFilterState)
final searchFilterStateProvider =
    NotifierProvider<SearchFilterState, SearchFilter>.internal(
  SearchFilterState.new,
  name: r'searchFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchFilterState = Notifier<SearchFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
