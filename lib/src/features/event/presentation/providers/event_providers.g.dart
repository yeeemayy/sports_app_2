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

String _$matchDetailHash() => r'69e689c8f5ae0c30253f743ab723f2bf0a2c74fd';

/// Generic match detail provider family keyed by [SportType].
///
/// Returns `Object` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchDetail)
/// ```
///
/// Copied from [matchDetail].
@ProviderFor(matchDetail)
const matchDetailProvider = MatchDetailFamily();

/// Generic match detail provider family keyed by [SportType].
///
/// Returns `Object` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchDetail)
/// ```
///
/// Copied from [matchDetail].
class MatchDetailFamily extends Family<AsyncValue<Object>> {
  /// Generic match detail provider family keyed by [SportType].
  ///
  /// Returns `Object` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchDetail)
  /// ```
  ///
  /// Copied from [matchDetail].
  const MatchDetailFamily();

  /// Generic match detail provider family keyed by [SportType].
  ///
  /// Returns `Object` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchDetail)
  /// ```
  ///
  /// Copied from [matchDetail].
  MatchDetailProvider call({
    required SportType sport,
    required String matchId,
  }) {
    return MatchDetailProvider(sport: sport, matchId: matchId);
  }

  @override
  MatchDetailProvider getProviderOverride(
    covariant MatchDetailProvider provider,
  ) {
    return call(sport: provider.sport, matchId: provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchDetailProvider';
}

/// Generic match detail provider family keyed by [SportType].
///
/// Returns `Object` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchDetail)
/// ```
///
/// Copied from [matchDetail].
class MatchDetailProvider extends AutoDisposeFutureProvider<Object> {
  /// Generic match detail provider family keyed by [SportType].
  ///
  /// Returns `Object` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchDetail)
  /// ```
  ///
  /// Copied from [matchDetail].
  MatchDetailProvider({required SportType sport, required String matchId})
    : this._internal(
        (ref) =>
            matchDetail(ref as MatchDetailRef, sport: sport, matchId: matchId),
        from: matchDetailProvider,
        name: r'matchDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchDetailHash,
        dependencies: MatchDetailFamily._dependencies,
        allTransitiveDependencies: MatchDetailFamily._allTransitiveDependencies,
        sport: sport,
        matchId: matchId,
      );

  MatchDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sport,
    required this.matchId,
  }) : super.internal();

  final SportType sport;
  final String matchId;

  @override
  Override overrideWith(
    FutureOr<Object> Function(MatchDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchDetailProvider._internal(
        (ref) => create(ref as MatchDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sport: sport,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Object> createElement() {
    return _MatchDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchDetailProvider &&
        other.sport == sport &&
        other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sport.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchDetailRef on AutoDisposeFutureProviderRef<Object> {
  /// The parameter `sport` of this provider.
  SportType get sport;

  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _MatchDetailProviderElement
    extends AutoDisposeFutureProviderElement<Object>
    with MatchDetailRef {
  _MatchDetailProviderElement(super.provider);

  @override
  SportType get sport => (origin as MatchDetailProvider).sport;
  @override
  String get matchId => (origin as MatchDetailProvider).matchId;
}

String _$matchEventsHash() => r'7e30cddfa7e528e9c3f6abc2131c8bb6104d236b';

/// Generic match events provider family keyed by [SportType].
///
/// Returns `Object?` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchEvents?)
/// ```
///
/// Copied from [matchEvents].
@ProviderFor(matchEvents)
const matchEventsProvider = MatchEventsFamily();

/// Generic match events provider family keyed by [SportType].
///
/// Returns `Object?` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchEvents?)
/// ```
///
/// Copied from [matchEvents].
class MatchEventsFamily extends Family<AsyncValue<Object?>> {
  /// Generic match events provider family keyed by [SportType].
  ///
  /// Returns `Object?` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchEvents?)
  /// ```
  ///
  /// Copied from [matchEvents].
  const MatchEventsFamily();

  /// Generic match events provider family keyed by [SportType].
  ///
  /// Returns `Object?` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchEvents?)
  /// ```
  ///
  /// Copied from [matchEvents].
  MatchEventsProvider call({
    required SportType sport,
    required String matchId,
  }) {
    return MatchEventsProvider(sport: sport, matchId: matchId);
  }

  @override
  MatchEventsProvider getProviderOverride(
    covariant MatchEventsProvider provider,
  ) {
    return call(sport: provider.sport, matchId: provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchEventsProvider';
}

/// Generic match events provider family keyed by [SportType].
///
/// Returns `Object?` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchEvents?)
/// ```
///
/// Copied from [matchEvents].
class MatchEventsProvider extends AutoDisposeFutureProvider<Object?> {
  /// Generic match events provider family keyed by [SportType].
  ///
  /// Returns `Object?` — callers cast to the expected sport-specific type:
  /// ```dart
  /// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
  ///     .whenData((r) => r as FootballMatchEvents?)
  /// ```
  ///
  /// Copied from [matchEvents].
  MatchEventsProvider({required SportType sport, required String matchId})
    : this._internal(
        (ref) =>
            matchEvents(ref as MatchEventsRef, sport: sport, matchId: matchId),
        from: matchEventsProvider,
        name: r'matchEventsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchEventsHash,
        dependencies: MatchEventsFamily._dependencies,
        allTransitiveDependencies: MatchEventsFamily._allTransitiveDependencies,
        sport: sport,
        matchId: matchId,
      );

  MatchEventsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sport,
    required this.matchId,
  }) : super.internal();

  final SportType sport;
  final String matchId;

  @override
  Override overrideWith(
    FutureOr<Object?> Function(MatchEventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchEventsProvider._internal(
        (ref) => create(ref as MatchEventsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sport: sport,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Object?> createElement() {
    return _MatchEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchEventsProvider &&
        other.sport == sport &&
        other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sport.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchEventsRef on AutoDisposeFutureProviderRef<Object?> {
  /// The parameter `sport` of this provider.
  SportType get sport;

  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _MatchEventsProviderElement
    extends AutoDisposeFutureProviderElement<Object?>
    with MatchEventsRef {
  _MatchEventsProviderElement(super.provider);

  @override
  SportType get sport => (origin as MatchEventsProvider).sport;
  @override
  String get matchId => (origin as MatchEventsProvider).matchId;
}

String _$sportMatchesPaginatedHash() =>
    r'd8c2c6da244415f8e04af177ab35c7815afd1faf';

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
