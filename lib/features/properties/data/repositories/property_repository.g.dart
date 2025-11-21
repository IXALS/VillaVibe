// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$propertyRepositoryHash() =>
    r'72a4f443d961fd943c784c2e902efceceb9719f3';

/// See also [propertyRepository].
@ProviderFor(propertyRepository)
final propertyRepositoryProvider =
    AutoDisposeProvider<PropertyRepository>.internal(
  propertyRepository,
  name: r'propertyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$propertyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PropertyRepositoryRef = AutoDisposeProviderRef<PropertyRepository>;
String _$hostPropertiesHash() => r'b26b6a1e68e81b47c408a856e7d08589701e9ee2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [hostProperties].
@ProviderFor(hostProperties)
const hostPropertiesProvider = HostPropertiesFamily();

/// See also [hostProperties].
class HostPropertiesFamily extends Family<AsyncValue<List<Property>>> {
  /// See also [hostProperties].
  const HostPropertiesFamily();

  /// See also [hostProperties].
  HostPropertiesProvider call(
    String hostId,
  ) {
    return HostPropertiesProvider(
      hostId,
    );
  }

  @override
  HostPropertiesProvider getProviderOverride(
    covariant HostPropertiesProvider provider,
  ) {
    return call(
      provider.hostId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'hostPropertiesProvider';
}

/// See also [hostProperties].
class HostPropertiesProvider extends AutoDisposeStreamProvider<List<Property>> {
  /// See also [hostProperties].
  HostPropertiesProvider(
    String hostId,
  ) : this._internal(
          (ref) => hostProperties(
            ref as HostPropertiesRef,
            hostId,
          ),
          from: hostPropertiesProvider,
          name: r'hostPropertiesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hostPropertiesHash,
          dependencies: HostPropertiesFamily._dependencies,
          allTransitiveDependencies:
              HostPropertiesFamily._allTransitiveDependencies,
          hostId: hostId,
        );

  HostPropertiesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hostId,
  }) : super.internal();

  final String hostId;

  @override
  Override overrideWith(
    Stream<List<Property>> Function(HostPropertiesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HostPropertiesProvider._internal(
        (ref) => create(ref as HostPropertiesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hostId: hostId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Property>> createElement() {
    return _HostPropertiesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HostPropertiesProvider && other.hostId == hostId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hostId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HostPropertiesRef on AutoDisposeStreamProviderRef<List<Property>> {
  /// The parameter `hostId` of this provider.
  String get hostId;
}

class _HostPropertiesProviderElement
    extends AutoDisposeStreamProviderElement<List<Property>>
    with HostPropertiesRef {
  _HostPropertiesProviderElement(super.provider);

  @override
  String get hostId => (origin as HostPropertiesProvider).hostId;
}

String _$allPropertiesHash() => r'0435ab45ae5ee489055e0750dd27c0f30b4e02c8';

/// See also [allProperties].
@ProviderFor(allProperties)
final allPropertiesProvider =
    AutoDisposeStreamProvider<List<Property>>.internal(
  allProperties,
  name: r'allPropertiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allPropertiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllPropertiesRef = AutoDisposeStreamProviderRef<List<Property>>;
String _$propertyHash() => r'ee00b253394cbff2206bf6b8fed75977222bf8d2';

/// See also [property].
@ProviderFor(property)
const propertyProvider = PropertyFamily();

/// See also [property].
class PropertyFamily extends Family<AsyncValue<Property?>> {
  /// See also [property].
  const PropertyFamily();

  /// See also [property].
  PropertyProvider call(
    String id,
  ) {
    return PropertyProvider(
      id,
    );
  }

  @override
  PropertyProvider getProviderOverride(
    covariant PropertyProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'propertyProvider';
}

/// See also [property].
class PropertyProvider extends AutoDisposeFutureProvider<Property?> {
  /// See also [property].
  PropertyProvider(
    String id,
  ) : this._internal(
          (ref) => property(
            ref as PropertyRef,
            id,
          ),
          from: propertyProvider,
          name: r'propertyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$propertyHash,
          dependencies: PropertyFamily._dependencies,
          allTransitiveDependencies: PropertyFamily._allTransitiveDependencies,
          id: id,
        );

  PropertyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Property?> Function(PropertyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PropertyProvider._internal(
        (ref) => create(ref as PropertyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Property?> createElement() {
    return _PropertyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PropertyProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PropertyRef on AutoDisposeFutureProviderRef<Property?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PropertyProviderElement
    extends AutoDisposeFutureProviderElement<Property?> with PropertyRef {
  _PropertyProviderElement(super.provider);

  @override
  String get id => (origin as PropertyProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
