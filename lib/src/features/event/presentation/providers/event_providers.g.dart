// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sportHotMatchesHash() => r'614573614c5a724d986d2e76febda145e6c18da0';

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

/// See also [sportHotMatches].
@ProviderFor(sportHotMatches)
const sportHotMatchesProvider = SportHotMatchesFamily();

/// See also [sportHotMatches].
class SportHotMatchesFamily extends Family<AsyncValue<List<SportMatch>>> {
  /// See also [sportHotMatches].
  const SportHotMatchesFamily();

  /// See also [sportHotMatches].
  SportHotMatchesProvider call({required SportType sport}) {
    return SportHotMatchesProvider(sport: sport);
  }

  @override
  SportHotMatchesProvider getProviderOverride(
    covariant SportHotMatchesProvider provider,
  ) {
    return call(sport: provider.sport);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sportHotMatchesProvider';
}

/// See also [sportHotMatches].
class SportHotMatchesProvider
    extends AutoDisposeFutureProvider<List<SportMatch>> {
  /// See also [sportHotMatches].
  SportHotMatchesProvider({required SportType sport})
    : this._internal(
        (ref) => sportHotMatches(ref as SportHotMatchesRef, sport: sport),
        from: sportHotMatchesProvider,
        name: r'sportHotMatchesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sportHotMatchesHash,
        dependencies: SportHotMatchesFamily._dependencies,
        allTransitiveDependencies:
            SportHotMatchesFamily._allTransitiveDependencies,
        sport: sport,
      );

  SportHotMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sport,
  }) : super.internal();

  final SportType sport;

  @override
  Override overrideWith(
    FutureOr<List<SportMatch>> Function(SportHotMatchesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SportHotMatchesProvider._internal(
        (ref) => create(ref as SportHotMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sport: sport,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SportMatch>> createElement() {
    return _SportHotMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SportHotMatchesProvider && other.sport == sport;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sport.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SportHotMatchesRef on AutoDisposeFutureProviderRef<List<SportMatch>> {
  /// The parameter `sport` of this provider.
  SportType get sport;
}

class _SportHotMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<SportMatch>>
    with SportHotMatchesRef {
  _SportHotMatchesProviderElement(super.provider);

  @override
  SportType get sport => (origin as SportHotMatchesProvider).sport;
}

String _$sportMatchesHash() => r'1f39dbcd4337dd676b3c4d613280a0bfa2496067';

/// See also [sportMatches].
@ProviderFor(sportMatches)
const sportMatchesProvider = SportMatchesFamily();

/// See also [sportMatches].
class SportMatchesFamily extends Family<AsyncValue<List<SportMatch>>> {
  /// See also [sportMatches].
  const SportMatchesFamily();

  /// See also [sportMatches].
  SportMatchesProvider call({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
  }) {
    return SportMatchesProvider(
      sport: sport,
      matchStatus: matchStatus,
      date: date,
    );
  }

  @override
  SportMatchesProvider getProviderOverride(
    covariant SportMatchesProvider provider,
  ) {
    return call(
      sport: provider.sport,
      matchStatus: provider.matchStatus,
      date: provider.date,
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
  String? get name => r'sportMatchesProvider';
}

/// See also [sportMatches].
class SportMatchesProvider extends AutoDisposeFutureProvider<List<SportMatch>> {
  /// See also [sportMatches].
  SportMatchesProvider({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
  }) : this._internal(
         (ref) => sportMatches(
           ref as SportMatchesRef,
           sport: sport,
           matchStatus: matchStatus,
           date: date,
         ),
         from: sportMatchesProvider,
         name: r'sportMatchesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$sportMatchesHash,
         dependencies: SportMatchesFamily._dependencies,
         allTransitiveDependencies:
             SportMatchesFamily._allTransitiveDependencies,
         sport: sport,
         matchStatus: matchStatus,
         date: date,
       );

  SportMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sport,
    required this.matchStatus,
    required this.date,
  }) : super.internal();

  final SportType sport;
  final String matchStatus;
  final String? date;

  @override
  Override overrideWith(
    FutureOr<List<SportMatch>> Function(SportMatchesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SportMatchesProvider._internal(
        (ref) => create(ref as SportMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sport: sport,
        matchStatus: matchStatus,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SportMatch>> createElement() {
    return _SportMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SportMatchesProvider &&
        other.sport == sport &&
        other.matchStatus == matchStatus &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sport.hashCode);
    hash = _SystemHash.combine(hash, matchStatus.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SportMatchesRef on AutoDisposeFutureProviderRef<List<SportMatch>> {
  /// The parameter `sport` of this provider.
  SportType get sport;

  /// The parameter `matchStatus` of this provider.
  String get matchStatus;

  /// The parameter `date` of this provider.
  String? get date;
}

class _SportMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<SportMatch>>
    with SportMatchesRef {
  _SportMatchesProviderElement(super.provider);

  @override
  SportType get sport => (origin as SportMatchesProvider).sport;
  @override
  String get matchStatus => (origin as SportMatchesProvider).matchStatus;
  @override
  String? get date => (origin as SportMatchesProvider).date;
}

String _$footballScheduledMatchesHash() =>
    r'ff8c0bbe84d0c0a492eb8fcf29cd4d796c4603ad';

/// See also [footballScheduledMatches].
@ProviderFor(footballScheduledMatches)
const footballScheduledMatchesProvider = FootballScheduledMatchesFamily();

/// See also [footballScheduledMatches].
class FootballScheduledMatchesFamily
    extends Family<AsyncValue<List<SportMatch>>> {
  /// See also [footballScheduledMatches].
  const FootballScheduledMatchesFamily();

  /// See also [footballScheduledMatches].
  FootballScheduledMatchesProvider call({required String date}) {
    return FootballScheduledMatchesProvider(date: date);
  }

  @override
  FootballScheduledMatchesProvider getProviderOverride(
    covariant FootballScheduledMatchesProvider provider,
  ) {
    return call(date: provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'footballScheduledMatchesProvider';
}

/// See also [footballScheduledMatches].
class FootballScheduledMatchesProvider
    extends AutoDisposeFutureProvider<List<SportMatch>> {
  /// See also [footballScheduledMatches].
  FootballScheduledMatchesProvider({required String date})
    : this._internal(
        (ref) => footballScheduledMatches(
          ref as FootballScheduledMatchesRef,
          date: date,
        ),
        from: footballScheduledMatchesProvider,
        name: r'footballScheduledMatchesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$footballScheduledMatchesHash,
        dependencies: FootballScheduledMatchesFamily._dependencies,
        allTransitiveDependencies:
            FootballScheduledMatchesFamily._allTransitiveDependencies,
        date: date,
      );

  FootballScheduledMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    FutureOr<List<SportMatch>> Function(FootballScheduledMatchesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FootballScheduledMatchesProvider._internal(
        (ref) => create(ref as FootballScheduledMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SportMatch>> createElement() {
    return _FootballScheduledMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FootballScheduledMatchesProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FootballScheduledMatchesRef
    on AutoDisposeFutureProviderRef<List<SportMatch>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _FootballScheduledMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<SportMatch>>
    with FootballScheduledMatchesRef {
  _FootballScheduledMatchesProviderElement(super.provider);

  @override
  String get date => (origin as FootballScheduledMatchesProvider).date;
}

String _$footballMatchDetailHash() =>
    r'fee2367404281b3d8df79162ae92234fcf3516ed';

/// See also [footballMatchDetail].
@ProviderFor(footballMatchDetail)
const footballMatchDetailProvider = FootballMatchDetailFamily();

/// See also [footballMatchDetail].
class FootballMatchDetailFamily
    extends Family<AsyncValue<FootballMatchDetail>> {
  /// See also [footballMatchDetail].
  const FootballMatchDetailFamily();

  /// See also [footballMatchDetail].
  FootballMatchDetailProvider call({required String matchId}) {
    return FootballMatchDetailProvider(matchId: matchId);
  }

  @override
  FootballMatchDetailProvider getProviderOverride(
    covariant FootballMatchDetailProvider provider,
  ) {
    return call(matchId: provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'footballMatchDetailProvider';
}

/// See also [footballMatchDetail].
class FootballMatchDetailProvider
    extends AutoDisposeFutureProvider<FootballMatchDetail> {
  /// See also [footballMatchDetail].
  FootballMatchDetailProvider({required String matchId})
    : this._internal(
        (ref) => footballMatchDetail(
          ref as FootballMatchDetailRef,
          matchId: matchId,
        ),
        from: footballMatchDetailProvider,
        name: r'footballMatchDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$footballMatchDetailHash,
        dependencies: FootballMatchDetailFamily._dependencies,
        allTransitiveDependencies:
            FootballMatchDetailFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  FootballMatchDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    FutureOr<FootballMatchDetail> Function(FootballMatchDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FootballMatchDetailProvider._internal(
        (ref) => create(ref as FootballMatchDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FootballMatchDetail> createElement() {
    return _FootballMatchDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FootballMatchDetailProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FootballMatchDetailRef
    on AutoDisposeFutureProviderRef<FootballMatchDetail> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _FootballMatchDetailProviderElement
    extends AutoDisposeFutureProviderElement<FootballMatchDetail>
    with FootballMatchDetailRef {
  _FootballMatchDetailProviderElement(super.provider);

  @override
  String get matchId => (origin as FootballMatchDetailProvider).matchId;
}

String _$footballMatchLineupsHash() =>
    r'8dbeccd1a467da0a5d06a536727fb6d29b725ede';

/// See also [footballMatchLineups].
@ProviderFor(footballMatchLineups)
const footballMatchLineupsProvider = FootballMatchLineupsFamily();

/// See also [footballMatchLineups].
class FootballMatchLineupsFamily extends Family<AsyncValue<FootballLineups?>> {
  /// See also [footballMatchLineups].
  const FootballMatchLineupsFamily();

  /// See also [footballMatchLineups].
  FootballMatchLineupsProvider call({required String matchId}) {
    return FootballMatchLineupsProvider(matchId: matchId);
  }

  @override
  FootballMatchLineupsProvider getProviderOverride(
    covariant FootballMatchLineupsProvider provider,
  ) {
    return call(matchId: provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'footballMatchLineupsProvider';
}

/// See also [footballMatchLineups].
class FootballMatchLineupsProvider
    extends AutoDisposeFutureProvider<FootballLineups?> {
  /// See also [footballMatchLineups].
  FootballMatchLineupsProvider({required String matchId})
    : this._internal(
        (ref) => footballMatchLineups(
          ref as FootballMatchLineupsRef,
          matchId: matchId,
        ),
        from: footballMatchLineupsProvider,
        name: r'footballMatchLineupsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$footballMatchLineupsHash,
        dependencies: FootballMatchLineupsFamily._dependencies,
        allTransitiveDependencies:
            FootballMatchLineupsFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  FootballMatchLineupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    FutureOr<FootballLineups?> Function(FootballMatchLineupsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FootballMatchLineupsProvider._internal(
        (ref) => create(ref as FootballMatchLineupsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FootballLineups?> createElement() {
    return _FootballMatchLineupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FootballMatchLineupsProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FootballMatchLineupsRef
    on AutoDisposeFutureProviderRef<FootballLineups?> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _FootballMatchLineupsProviderElement
    extends AutoDisposeFutureProviderElement<FootballLineups?>
    with FootballMatchLineupsRef {
  _FootballMatchLineupsProviderElement(super.provider);

  @override
  String get matchId => (origin as FootballMatchLineupsProvider).matchId;
}

String _$footballMatchEventsKeyHash() =>
    r'f2b3f372887348b817427adc8edd8c2b3babd5a5';

/// See also [footballMatchEventsKey].
@ProviderFor(footballMatchEventsKey)
const footballMatchEventsKeyProvider = FootballMatchEventsKeyFamily();

/// See also [footballMatchEventsKey].
class FootballMatchEventsKeyFamily
    extends Family<AsyncValue<FootballMatchEvents?>> {
  /// See also [footballMatchEventsKey].
  const FootballMatchEventsKeyFamily();

  /// See also [footballMatchEventsKey].
  FootballMatchEventsKeyProvider call({required String matchId}) {
    return FootballMatchEventsKeyProvider(matchId: matchId);
  }

  @override
  FootballMatchEventsKeyProvider getProviderOverride(
    covariant FootballMatchEventsKeyProvider provider,
  ) {
    return call(matchId: provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'footballMatchEventsKeyProvider';
}

/// See also [footballMatchEventsKey].
class FootballMatchEventsKeyProvider
    extends AutoDisposeFutureProvider<FootballMatchEvents?> {
  /// See also [footballMatchEventsKey].
  FootballMatchEventsKeyProvider({required String matchId})
    : this._internal(
        (ref) => footballMatchEventsKey(
          ref as FootballMatchEventsKeyRef,
          matchId: matchId,
        ),
        from: footballMatchEventsKeyProvider,
        name: r'footballMatchEventsKeyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$footballMatchEventsKeyHash,
        dependencies: FootballMatchEventsKeyFamily._dependencies,
        allTransitiveDependencies:
            FootballMatchEventsKeyFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  FootballMatchEventsKeyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    FutureOr<FootballMatchEvents?> Function(FootballMatchEventsKeyRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FootballMatchEventsKeyProvider._internal(
        (ref) => create(ref as FootballMatchEventsKeyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FootballMatchEvents?> createElement() {
    return _FootballMatchEventsKeyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FootballMatchEventsKeyProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FootballMatchEventsKeyRef
    on AutoDisposeFutureProviderRef<FootballMatchEvents?> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _FootballMatchEventsKeyProviderElement
    extends AutoDisposeFutureProviderElement<FootballMatchEvents?>
    with FootballMatchEventsKeyRef {
  _FootballMatchEventsKeyProviderElement(super.provider);

  @override
  String get matchId => (origin as FootballMatchEventsKeyProvider).matchId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
