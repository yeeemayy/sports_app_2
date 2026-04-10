// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sportRealtimeHash() => r'864f26ff2dac06a43bd9b4a6f66e1eac45e3b2ed';

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

abstract class _$SportRealtime
    extends BuildlessAutoDisposeNotifier<Map<String, SportRealtimeData>> {
  late final SportType arg;

  Map<String, SportRealtimeData> build(SportType arg);
}

/// Generic realtime provider family keyed by [SportType].
///
/// Replaces the 6 sport-specific notifier classes. Stores typed
/// [SportRealtimeData] values; consumers cast to the expected sport type:
///
/// ```dart
/// final rt = ref.watch(
///   sportRealtimeProvider(SportType.basketball)
///     .select((map) => map[matchId] as BasketballRealtimeData?),
/// );
/// ```
///
/// Copied from [SportRealtime].
@ProviderFor(SportRealtime)
const sportRealtimeProvider = SportRealtimeFamily();

/// Generic realtime provider family keyed by [SportType].
///
/// Replaces the 6 sport-specific notifier classes. Stores typed
/// [SportRealtimeData] values; consumers cast to the expected sport type:
///
/// ```dart
/// final rt = ref.watch(
///   sportRealtimeProvider(SportType.basketball)
///     .select((map) => map[matchId] as BasketballRealtimeData?),
/// );
/// ```
///
/// Copied from [SportRealtime].
class SportRealtimeFamily extends Family<Map<String, SportRealtimeData>> {
  /// Generic realtime provider family keyed by [SportType].
  ///
  /// Replaces the 6 sport-specific notifier classes. Stores typed
  /// [SportRealtimeData] values; consumers cast to the expected sport type:
  ///
  /// ```dart
  /// final rt = ref.watch(
  ///   sportRealtimeProvider(SportType.basketball)
  ///     .select((map) => map[matchId] as BasketballRealtimeData?),
  /// );
  /// ```
  ///
  /// Copied from [SportRealtime].
  const SportRealtimeFamily();

  /// Generic realtime provider family keyed by [SportType].
  ///
  /// Replaces the 6 sport-specific notifier classes. Stores typed
  /// [SportRealtimeData] values; consumers cast to the expected sport type:
  ///
  /// ```dart
  /// final rt = ref.watch(
  ///   sportRealtimeProvider(SportType.basketball)
  ///     .select((map) => map[matchId] as BasketballRealtimeData?),
  /// );
  /// ```
  ///
  /// Copied from [SportRealtime].
  SportRealtimeProvider call(SportType arg) {
    return SportRealtimeProvider(arg);
  }

  @override
  SportRealtimeProvider getProviderOverride(
    covariant SportRealtimeProvider provider,
  ) {
    return call(provider.arg);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sportRealtimeProvider';
}

/// Generic realtime provider family keyed by [SportType].
///
/// Replaces the 6 sport-specific notifier classes. Stores typed
/// [SportRealtimeData] values; consumers cast to the expected sport type:
///
/// ```dart
/// final rt = ref.watch(
///   sportRealtimeProvider(SportType.basketball)
///     .select((map) => map[matchId] as BasketballRealtimeData?),
/// );
/// ```
///
/// Copied from [SportRealtime].
class SportRealtimeProvider
    extends
        AutoDisposeNotifierProviderImpl<
          SportRealtime,
          Map<String, SportRealtimeData>
        > {
  /// Generic realtime provider family keyed by [SportType].
  ///
  /// Replaces the 6 sport-specific notifier classes. Stores typed
  /// [SportRealtimeData] values; consumers cast to the expected sport type:
  ///
  /// ```dart
  /// final rt = ref.watch(
  ///   sportRealtimeProvider(SportType.basketball)
  ///     .select((map) => map[matchId] as BasketballRealtimeData?),
  /// );
  /// ```
  ///
  /// Copied from [SportRealtime].
  SportRealtimeProvider(SportType arg)
    : this._internal(
        () => SportRealtime()..arg = arg,
        from: sportRealtimeProvider,
        name: r'sportRealtimeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sportRealtimeHash,
        dependencies: SportRealtimeFamily._dependencies,
        allTransitiveDependencies:
            SportRealtimeFamily._allTransitiveDependencies,
        arg: arg,
      );

  SportRealtimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.arg,
  }) : super.internal();

  final SportType arg;

  @override
  Map<String, SportRealtimeData> runNotifierBuild(
    covariant SportRealtime notifier,
  ) {
    return notifier.build(arg);
  }

  @override
  Override overrideWith(SportRealtime Function() create) {
    return ProviderOverride(
      origin: this,
      override: SportRealtimeProvider._internal(
        () => create()..arg = arg,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        arg: arg,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    SportRealtime,
    Map<String, SportRealtimeData>
  >
  createElement() {
    return _SportRealtimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SportRealtimeProvider && other.arg == arg;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, arg.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SportRealtimeRef
    on AutoDisposeNotifierProviderRef<Map<String, SportRealtimeData>> {
  /// The parameter `arg` of this provider.
  SportType get arg;
}

class _SportRealtimeProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          SportRealtime,
          Map<String, SportRealtimeData>
        >
    with SportRealtimeRef {
  _SportRealtimeProviderElement(super.provider);

  @override
  SportType get arg => (origin as SportRealtimeProvider).arg;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
