// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'212a462c12fe18c6286087a226824d813a892c5d';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider =
    AutoDisposeProvider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryRepositoryRef = AutoDisposeProviderRef<CategoryRepository>;
String _$categoriesHash() => r'a0ea0c5c5ce76a7b15f9c3c0423134a1c0615e6b';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeStreamProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
