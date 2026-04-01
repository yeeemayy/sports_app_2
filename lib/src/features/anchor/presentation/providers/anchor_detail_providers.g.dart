// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$anchorDetailHash() => r'510cecd5d3c1ce869a9e996a18745e6b0ff9aa3a';

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

/// See also [anchorDetail].
@ProviderFor(anchorDetail)
const anchorDetailProvider = AnchorDetailFamily();

/// See also [anchorDetail].
class AnchorDetailFamily extends Family<AsyncValue<AnchorDetailModel>> {
  /// See also [anchorDetail].
  const AnchorDetailFamily();

  /// See also [anchorDetail].
  AnchorDetailProvider call(int anchorId) {
    return AnchorDetailProvider(anchorId);
  }

  @override
  AnchorDetailProvider getProviderOverride(
    covariant AnchorDetailProvider provider,
  ) {
    return call(provider.anchorId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'anchorDetailProvider';
}

/// See also [anchorDetail].
class AnchorDetailProvider
    extends AutoDisposeFutureProvider<AnchorDetailModel> {
  /// See also [anchorDetail].
  AnchorDetailProvider(int anchorId)
    : this._internal(
        (ref) => anchorDetail(ref as AnchorDetailRef, anchorId),
        from: anchorDetailProvider,
        name: r'anchorDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$anchorDetailHash,
        dependencies: AnchorDetailFamily._dependencies,
        allTransitiveDependencies:
            AnchorDetailFamily._allTransitiveDependencies,
        anchorId: anchorId,
      );

  AnchorDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.anchorId,
  }) : super.internal();

  final int anchorId;

  @override
  Override overrideWith(
    FutureOr<AnchorDetailModel> Function(AnchorDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnchorDetailProvider._internal(
        (ref) => create(ref as AnchorDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        anchorId: anchorId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AnchorDetailModel> createElement() {
    return _AnchorDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnchorDetailProvider && other.anchorId == anchorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, anchorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnchorDetailRef on AutoDisposeFutureProviderRef<AnchorDetailModel> {
  /// The parameter `anchorId` of this provider.
  int get anchorId;
}

class _AnchorDetailProviderElement
    extends AutoDisposeFutureProviderElement<AnchorDetailModel>
    with AnchorDetailRef {
  _AnchorDetailProviderElement(super.provider);

  @override
  int get anchorId => (origin as AnchorDetailProvider).anchorId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
