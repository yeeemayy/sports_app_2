// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$anchorListHash() => r'508971a93513fe96f7590e645b29c509bd1c672b';

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

/// See also [anchorList].
@ProviderFor(anchorList)
const anchorListProvider = AnchorListFamily();

/// See also [anchorList].
class AnchorListFamily
    extends Family<AsyncValue<PaginatedResponse<AnchorModel>>> {
  /// See also [anchorList].
  const AnchorListFamily();

  /// See also [anchorList].
  AnchorListProvider call({int page = 1}) {
    return AnchorListProvider(page: page);
  }

  @override
  AnchorListProvider getProviderOverride(
    covariant AnchorListProvider provider,
  ) {
    return call(page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'anchorListProvider';
}

/// See also [anchorList].
class AnchorListProvider
    extends AutoDisposeFutureProvider<PaginatedResponse<AnchorModel>> {
  /// See also [anchorList].
  AnchorListProvider({int page = 1})
    : this._internal(
        (ref) => anchorList(ref as AnchorListRef, page: page),
        from: anchorListProvider,
        name: r'anchorListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$anchorListHash,
        dependencies: AnchorListFamily._dependencies,
        allTransitiveDependencies: AnchorListFamily._allTransitiveDependencies,
        page: page,
      );

  AnchorListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  Override overrideWith(
    FutureOr<PaginatedResponse<AnchorModel>> Function(AnchorListRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnchorListProvider._internal(
        (ref) => create(ref as AnchorListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaginatedResponse<AnchorModel>>
  createElement() {
    return _AnchorListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnchorListProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnchorListRef
    on AutoDisposeFutureProviderRef<PaginatedResponse<AnchorModel>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _AnchorListProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResponse<AnchorModel>>
    with AnchorListRef {
  _AnchorListProviderElement(super.provider);

  @override
  int get page => (origin as AnchorListProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
