// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'im_token_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imTokenHash() => r'864549d8d7662cc0914fe035e93e821c4c27ab10';

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

/// See also [imToken].
@ProviderFor(imToken)
const imTokenProvider = ImTokenFamily();

/// See also [imToken].
class ImTokenFamily extends Family<AsyncValue<ImTokenModel>> {
  /// See also [imToken].
  const ImTokenFamily();

  /// See also [imToken].
  ImTokenProvider call(int cid) {
    return ImTokenProvider(cid);
  }

  @override
  ImTokenProvider getProviderOverride(covariant ImTokenProvider provider) {
    return call(provider.cid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imTokenProvider';
}

/// See also [imToken].
class ImTokenProvider extends AutoDisposeFutureProvider<ImTokenModel> {
  /// See also [imToken].
  ImTokenProvider(int cid)
    : this._internal(
        (ref) => imToken(ref as ImTokenRef, cid),
        from: imTokenProvider,
        name: r'imTokenProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imTokenHash,
        dependencies: ImTokenFamily._dependencies,
        allTransitiveDependencies: ImTokenFamily._allTransitiveDependencies,
        cid: cid,
      );

  ImTokenProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cid,
  }) : super.internal();

  final int cid;

  @override
  Override overrideWith(
    FutureOr<ImTokenModel> Function(ImTokenRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImTokenProvider._internal(
        (ref) => create(ref as ImTokenRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cid: cid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ImTokenModel> createElement() {
    return _ImTokenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImTokenProvider && other.cid == cid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImTokenRef on AutoDisposeFutureProviderRef<ImTokenModel> {
  /// The parameter `cid` of this provider.
  int get cid;
}

class _ImTokenProviderElement
    extends AutoDisposeFutureProviderElement<ImTokenModel>
    with ImTokenRef {
  _ImTokenProviderElement(super.provider);

  @override
  int get cid => (origin as ImTokenProvider).cid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
