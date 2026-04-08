// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$footballScheduledMatchesHash() =>
    r'ff8c0bbe84d0c0a492eb8fcf29cd4d796c4603ad';

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

String _$basketballMatchDetailHash() =>
    r'6963f7a2a3cc2f4dc39f7e156cdebd43046be78d';

/// See also [basketballMatchDetail].
@ProviderFor(basketballMatchDetail)
const basketballMatchDetailProvider = BasketballMatchDetailFamily();

/// See also [basketballMatchDetail].
class BasketballMatchDetailFamily
    extends Family<AsyncValue<BasketballMatchDetail>> {
  /// See also [basketballMatchDetail].
  const BasketballMatchDetailFamily();

  /// See also [basketballMatchDetail].
  BasketballMatchDetailProvider call({required String matchId}) {
    return BasketballMatchDetailProvider(matchId: matchId);
  }

  @override
  BasketballMatchDetailProvider getProviderOverride(
    covariant BasketballMatchDetailProvider provider,
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
  String? get name => r'basketballMatchDetailProvider';
}

/// See also [basketballMatchDetail].
class BasketballMatchDetailProvider
    extends AutoDisposeFutureProvider<BasketballMatchDetail> {
  /// See also [basketballMatchDetail].
  BasketballMatchDetailProvider({required String matchId})
    : this._internal(
        (ref) => basketballMatchDetail(
          ref as BasketballMatchDetailRef,
          matchId: matchId,
        ),
        from: basketballMatchDetailProvider,
        name: r'basketballMatchDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$basketballMatchDetailHash,
        dependencies: BasketballMatchDetailFamily._dependencies,
        allTransitiveDependencies:
            BasketballMatchDetailFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  BasketballMatchDetailProvider._internal(
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
    FutureOr<BasketballMatchDetail> Function(BasketballMatchDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BasketballMatchDetailProvider._internal(
        (ref) => create(ref as BasketballMatchDetailRef),
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
  AutoDisposeFutureProviderElement<BasketballMatchDetail> createElement() {
    return _BasketballMatchDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BasketballMatchDetailProvider && other.matchId == matchId;
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
mixin BasketballMatchDetailRef
    on AutoDisposeFutureProviderRef<BasketballMatchDetail> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _BasketballMatchDetailProviderElement
    extends AutoDisposeFutureProviderElement<BasketballMatchDetail>
    with BasketballMatchDetailRef {
  _BasketballMatchDetailProviderElement(super.provider);

  @override
  String get matchId => (origin as BasketballMatchDetailProvider).matchId;
}

String _$basketballMatchEventsKeyHash() =>
    r'600a715e3c02ea5ecb6e40feac30b9db7ab81de0';

/// See also [basketballMatchEventsKey].
@ProviderFor(basketballMatchEventsKey)
const basketballMatchEventsKeyProvider = BasketballMatchEventsKeyFamily();

/// See also [basketballMatchEventsKey].
class BasketballMatchEventsKeyFamily
    extends Family<AsyncValue<BasketballMatchEventsData?>> {
  /// See also [basketballMatchEventsKey].
  const BasketballMatchEventsKeyFamily();

  /// See also [basketballMatchEventsKey].
  BasketballMatchEventsKeyProvider call({required String matchId}) {
    return BasketballMatchEventsKeyProvider(matchId: matchId);
  }

  @override
  BasketballMatchEventsKeyProvider getProviderOverride(
    covariant BasketballMatchEventsKeyProvider provider,
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
  String? get name => r'basketballMatchEventsKeyProvider';
}

/// See also [basketballMatchEventsKey].
class BasketballMatchEventsKeyProvider
    extends AutoDisposeFutureProvider<BasketballMatchEventsData?> {
  /// See also [basketballMatchEventsKey].
  BasketballMatchEventsKeyProvider({required String matchId})
    : this._internal(
        (ref) => basketballMatchEventsKey(
          ref as BasketballMatchEventsKeyRef,
          matchId: matchId,
        ),
        from: basketballMatchEventsKeyProvider,
        name: r'basketballMatchEventsKeyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$basketballMatchEventsKeyHash,
        dependencies: BasketballMatchEventsKeyFamily._dependencies,
        allTransitiveDependencies:
            BasketballMatchEventsKeyFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  BasketballMatchEventsKeyProvider._internal(
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
    FutureOr<BasketballMatchEventsData?> Function(
      BasketballMatchEventsKeyRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BasketballMatchEventsKeyProvider._internal(
        (ref) => create(ref as BasketballMatchEventsKeyRef),
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
  AutoDisposeFutureProviderElement<BasketballMatchEventsData?> createElement() {
    return _BasketballMatchEventsKeyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BasketballMatchEventsKeyProvider &&
        other.matchId == matchId;
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
mixin BasketballMatchEventsKeyRef
    on AutoDisposeFutureProviderRef<BasketballMatchEventsData?> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _BasketballMatchEventsKeyProviderElement
    extends AutoDisposeFutureProviderElement<BasketballMatchEventsData?>
    with BasketballMatchEventsKeyRef {
  _BasketballMatchEventsKeyProviderElement(super.provider);

  @override
  String get matchId => (origin as BasketballMatchEventsKeyProvider).matchId;
}

String _$basketballTeamSquadHash() =>
    r'44a89a4bdbe7895214ef122e6413adf64a4c8d80';

/// See also [basketballTeamSquad].
@ProviderFor(basketballTeamSquad)
const basketballTeamSquadProvider = BasketballTeamSquadFamily();

/// See also [basketballTeamSquad].
class BasketballTeamSquadFamily
    extends Family<AsyncValue<List<BasketballPlayer>>> {
  /// See also [basketballTeamSquad].
  const BasketballTeamSquadFamily();

  /// See also [basketballTeamSquad].
  BasketballTeamSquadProvider call({required String teamId}) {
    return BasketballTeamSquadProvider(teamId: teamId);
  }

  @override
  BasketballTeamSquadProvider getProviderOverride(
    covariant BasketballTeamSquadProvider provider,
  ) {
    return call(teamId: provider.teamId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'basketballTeamSquadProvider';
}

/// See also [basketballTeamSquad].
class BasketballTeamSquadProvider
    extends AutoDisposeFutureProvider<List<BasketballPlayer>> {
  /// See also [basketballTeamSquad].
  BasketballTeamSquadProvider({required String teamId})
    : this._internal(
        (ref) =>
            basketballTeamSquad(ref as BasketballTeamSquadRef, teamId: teamId),
        from: basketballTeamSquadProvider,
        name: r'basketballTeamSquadProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$basketballTeamSquadHash,
        dependencies: BasketballTeamSquadFamily._dependencies,
        allTransitiveDependencies:
            BasketballTeamSquadFamily._allTransitiveDependencies,
        teamId: teamId,
      );

  BasketballTeamSquadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.teamId,
  }) : super.internal();

  final String teamId;

  @override
  Override overrideWith(
    FutureOr<List<BasketballPlayer>> Function(BasketballTeamSquadRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BasketballTeamSquadProvider._internal(
        (ref) => create(ref as BasketballTeamSquadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        teamId: teamId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BasketballPlayer>> createElement() {
    return _BasketballTeamSquadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BasketballTeamSquadProvider && other.teamId == teamId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, teamId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BasketballTeamSquadRef
    on AutoDisposeFutureProviderRef<List<BasketballPlayer>> {
  /// The parameter `teamId` of this provider.
  String get teamId;
}

class _BasketballTeamSquadProviderElement
    extends AutoDisposeFutureProviderElement<List<BasketballPlayer>>
    with BasketballTeamSquadRef {
  _BasketballTeamSquadProviderElement(super.provider);

  @override
  String get teamId => (origin as BasketballTeamSquadProvider).teamId;
}

String _$sportMatchesPaginatedHash() =>
    r'deae687e672944ccd2882c02768841aa274fcd12';

abstract class _$SportMatchesPaginated
    extends BuildlessAutoDisposeAsyncNotifier<PaginatedMatchResult> {
  late final SportType sport;
  late final String matchStatus;
  late final String? date;
  late final bool isHot;

  FutureOr<PaginatedMatchResult> build({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
    bool isHot = false,
  });
}

/// See also [SportMatchesPaginated].
@ProviderFor(SportMatchesPaginated)
const sportMatchesPaginatedProvider = SportMatchesPaginatedFamily();

/// See also [SportMatchesPaginated].
class SportMatchesPaginatedFamily
    extends Family<AsyncValue<PaginatedMatchResult>> {
  /// See also [SportMatchesPaginated].
  const SportMatchesPaginatedFamily();

  /// See also [SportMatchesPaginated].
  SportMatchesPaginatedProvider call({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
    bool isHot = false,
  }) {
    return SportMatchesPaginatedProvider(
      sport: sport,
      matchStatus: matchStatus,
      date: date,
      isHot: isHot,
    );
  }

  @override
  SportMatchesPaginatedProvider getProviderOverride(
    covariant SportMatchesPaginatedProvider provider,
  ) {
    return call(
      sport: provider.sport,
      matchStatus: provider.matchStatus,
      date: provider.date,
      isHot: provider.isHot,
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
  String? get name => r'sportMatchesPaginatedProvider';
}

/// See also [SportMatchesPaginated].
class SportMatchesPaginatedProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SportMatchesPaginated,
          PaginatedMatchResult
        > {
  /// See also [SportMatchesPaginated].
  SportMatchesPaginatedProvider({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
    bool isHot = false,
  }) : this._internal(
         () => SportMatchesPaginated()
           ..sport = sport
           ..matchStatus = matchStatus
           ..date = date
           ..isHot = isHot,
         from: sportMatchesPaginatedProvider,
         name: r'sportMatchesPaginatedProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$sportMatchesPaginatedHash,
         dependencies: SportMatchesPaginatedFamily._dependencies,
         allTransitiveDependencies:
             SportMatchesPaginatedFamily._allTransitiveDependencies,
         sport: sport,
         matchStatus: matchStatus,
         date: date,
         isHot: isHot,
       );

  SportMatchesPaginatedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sport,
    required this.matchStatus,
    required this.date,
    required this.isHot,
  }) : super.internal();

  final SportType sport;
  final String matchStatus;
  final String? date;
  final bool isHot;

  @override
  FutureOr<PaginatedMatchResult> runNotifierBuild(
    covariant SportMatchesPaginated notifier,
  ) {
    return notifier.build(
      sport: sport,
      matchStatus: matchStatus,
      date: date,
      isHot: isHot,
    );
  }

  @override
  Override overrideWith(SportMatchesPaginated Function() create) {
    return ProviderOverride(
      origin: this,
      override: SportMatchesPaginatedProvider._internal(
        () => create()
          ..sport = sport
          ..matchStatus = matchStatus
          ..date = date
          ..isHot = isHot,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sport: sport,
        matchStatus: matchStatus,
        date: date,
        isHot: isHot,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    SportMatchesPaginated,
    PaginatedMatchResult
  >
  createElement() {
    return _SportMatchesPaginatedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SportMatchesPaginatedProvider &&
        other.sport == sport &&
        other.matchStatus == matchStatus &&
        other.date == date &&
        other.isHot == isHot;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sport.hashCode);
    hash = _SystemHash.combine(hash, matchStatus.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, isHot.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SportMatchesPaginatedRef
    on AutoDisposeAsyncNotifierProviderRef<PaginatedMatchResult> {
  /// The parameter `sport` of this provider.
  SportType get sport;

  /// The parameter `matchStatus` of this provider.
  String get matchStatus;

  /// The parameter `date` of this provider.
  String? get date;

  /// The parameter `isHot` of this provider.
  bool get isHot;
}

class _SportMatchesPaginatedProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SportMatchesPaginated,
          PaginatedMatchResult
        >
    with SportMatchesPaginatedRef {
  _SportMatchesPaginatedProviderElement(super.provider);

  @override
  SportType get sport => (origin as SportMatchesPaginatedProvider).sport;
  @override
  String get matchStatus =>
      (origin as SportMatchesPaginatedProvider).matchStatus;
  @override
  String? get date => (origin as SportMatchesPaginatedProvider).date;
  @override
  bool get isHot => (origin as SportMatchesPaginatedProvider).isHot;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
