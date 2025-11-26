// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredPropertiesHash() =>
    r'0e09a39682b1e9dc8df7f9d4eb327820c336e775';

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
String _$searchFilterStateHash() => r'57f7d5c8bcffa3eb66a604c66bca12a2e1efb753';

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
