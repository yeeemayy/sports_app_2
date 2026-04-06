// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'am_football_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AmFootballMatch _$AmFootballMatchFromJson(Map<String, dynamic> json) {
  return _AmFootballMatch.fromJson(json);
}

/// @nodoc
mixin _$AmFootballMatch {
  String get id => throw _privateConstructorUsedError;
  int get statusId => throw _privateConstructorUsedError;
  String get matchTimeSim => throw _privateConstructorUsedError;
  String get homeName => throw _privateConstructorUsedError;
  String get homeLogo => throw _privateConstructorUsedError;
  String get homeScore => throw _privateConstructorUsedError;
  String get awayName => throw _privateConstructorUsedError;
  String get awayLogo => throw _privateConstructorUsedError;
  String get awayScore => throw _privateConstructorUsedError;
  String get leagueName => throw _privateConstructorUsedError;
  String get leagueLogo => throw _privateConstructorUsedError;
  int? get matchTime => throw _privateConstructorUsedError;

  /// Per-quarter breakdown keyed by "p1".."p4" plus "ft" (total points).
  Map<String, dynamic>? get scores => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<dynamic>? get oddsEuro => throw _privateConstructorUsedError;
  String? get statusDescription => throw _privateConstructorUsedError;

  /// Serializes this AmFootballMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AmFootballMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AmFootballMatchCopyWith<AmFootballMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AmFootballMatchCopyWith<$Res> {
  factory $AmFootballMatchCopyWith(
    AmFootballMatch value,
    $Res Function(AmFootballMatch) then,
  ) = _$AmFootballMatchCopyWithImpl<$Res, AmFootballMatch>;
  @useResult
  $Res call({
    String id,
    int statusId,
    String matchTimeSim,
    String homeName,
    String homeLogo,
    String homeScore,
    String awayName,
    String awayLogo,
    String awayScore,
    String leagueName,
    String leagueLogo,
    int? matchTime,
    Map<String, dynamic>? scores,
    String? description,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class _$AmFootballMatchCopyWithImpl<$Res, $Val extends AmFootballMatch>
    implements $AmFootballMatchCopyWith<$Res> {
  _$AmFootballMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AmFootballMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statusId = null,
    Object? matchTimeSim = null,
    Object? homeName = null,
    Object? homeLogo = null,
    Object? homeScore = null,
    Object? awayName = null,
    Object? awayLogo = null,
    Object? awayScore = null,
    Object? leagueName = null,
    Object? leagueLogo = null,
    Object? matchTime = freezed,
    Object? scores = freezed,
    Object? description = freezed,
    Object? oddsEuro = freezed,
    Object? statusDescription = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            statusId: null == statusId
                ? _value.statusId
                : statusId // ignore: cast_nullable_to_non_nullable
                      as int,
            matchTimeSim: null == matchTimeSim
                ? _value.matchTimeSim
                : matchTimeSim // ignore: cast_nullable_to_non_nullable
                      as String,
            homeName: null == homeName
                ? _value.homeName
                : homeName // ignore: cast_nullable_to_non_nullable
                      as String,
            homeLogo: null == homeLogo
                ? _value.homeLogo
                : homeLogo // ignore: cast_nullable_to_non_nullable
                      as String,
            homeScore: null == homeScore
                ? _value.homeScore
                : homeScore // ignore: cast_nullable_to_non_nullable
                      as String,
            awayName: null == awayName
                ? _value.awayName
                : awayName // ignore: cast_nullable_to_non_nullable
                      as String,
            awayLogo: null == awayLogo
                ? _value.awayLogo
                : awayLogo // ignore: cast_nullable_to_non_nullable
                      as String,
            awayScore: null == awayScore
                ? _value.awayScore
                : awayScore // ignore: cast_nullable_to_non_nullable
                      as String,
            leagueName: null == leagueName
                ? _value.leagueName
                : leagueName // ignore: cast_nullable_to_non_nullable
                      as String,
            leagueLogo: null == leagueLogo
                ? _value.leagueLogo
                : leagueLogo // ignore: cast_nullable_to_non_nullable
                      as String,
            matchTime: freezed == matchTime
                ? _value.matchTime
                : matchTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            scores: freezed == scores
                ? _value.scores
                : scores // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            oddsEuro: freezed == oddsEuro
                ? _value.oddsEuro
                : oddsEuro // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            statusDescription: freezed == statusDescription
                ? _value.statusDescription
                : statusDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AmFootballMatchImplCopyWith<$Res>
    implements $AmFootballMatchCopyWith<$Res> {
  factory _$$AmFootballMatchImplCopyWith(
    _$AmFootballMatchImpl value,
    $Res Function(_$AmFootballMatchImpl) then,
  ) = __$$AmFootballMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int statusId,
    String matchTimeSim,
    String homeName,
    String homeLogo,
    String homeScore,
    String awayName,
    String awayLogo,
    String awayScore,
    String leagueName,
    String leagueLogo,
    int? matchTime,
    Map<String, dynamic>? scores,
    String? description,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class __$$AmFootballMatchImplCopyWithImpl<$Res>
    extends _$AmFootballMatchCopyWithImpl<$Res, _$AmFootballMatchImpl>
    implements _$$AmFootballMatchImplCopyWith<$Res> {
  __$$AmFootballMatchImplCopyWithImpl(
    _$AmFootballMatchImpl _value,
    $Res Function(_$AmFootballMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AmFootballMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statusId = null,
    Object? matchTimeSim = null,
    Object? homeName = null,
    Object? homeLogo = null,
    Object? homeScore = null,
    Object? awayName = null,
    Object? awayLogo = null,
    Object? awayScore = null,
    Object? leagueName = null,
    Object? leagueLogo = null,
    Object? matchTime = freezed,
    Object? scores = freezed,
    Object? description = freezed,
    Object? oddsEuro = freezed,
    Object? statusDescription = freezed,
  }) {
    return _then(
      _$AmFootballMatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        statusId: null == statusId
            ? _value.statusId
            : statusId // ignore: cast_nullable_to_non_nullable
                  as int,
        matchTimeSim: null == matchTimeSim
            ? _value.matchTimeSim
            : matchTimeSim // ignore: cast_nullable_to_non_nullable
                  as String,
        homeName: null == homeName
            ? _value.homeName
            : homeName // ignore: cast_nullable_to_non_nullable
                  as String,
        homeLogo: null == homeLogo
            ? _value.homeLogo
            : homeLogo // ignore: cast_nullable_to_non_nullable
                  as String,
        homeScore: null == homeScore
            ? _value.homeScore
            : homeScore // ignore: cast_nullable_to_non_nullable
                  as String,
        awayName: null == awayName
            ? _value.awayName
            : awayName // ignore: cast_nullable_to_non_nullable
                  as String,
        awayLogo: null == awayLogo
            ? _value.awayLogo
            : awayLogo // ignore: cast_nullable_to_non_nullable
                  as String,
        awayScore: null == awayScore
            ? _value.awayScore
            : awayScore // ignore: cast_nullable_to_non_nullable
                  as String,
        leagueName: null == leagueName
            ? _value.leagueName
            : leagueName // ignore: cast_nullable_to_non_nullable
                  as String,
        leagueLogo: null == leagueLogo
            ? _value.leagueLogo
            : leagueLogo // ignore: cast_nullable_to_non_nullable
                  as String,
        matchTime: freezed == matchTime
            ? _value.matchTime
            : matchTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        scores: freezed == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        oddsEuro: freezed == oddsEuro
            ? _value._oddsEuro
            : oddsEuro // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        statusDescription: freezed == statusDescription
            ? _value.statusDescription
            : statusDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AmFootballMatchImpl extends _AmFootballMatch {
  const _$AmFootballMatchImpl({
    required this.id,
    required this.statusId,
    required this.matchTimeSim,
    required this.homeName,
    required this.homeLogo,
    required this.homeScore,
    required this.awayName,
    required this.awayLogo,
    required this.awayScore,
    required this.leagueName,
    required this.leagueLogo,
    this.matchTime,
    final Map<String, dynamic>? scores,
    this.description,
    final List<dynamic>? oddsEuro,
    this.statusDescription,
  }) : _scores = scores,
       _oddsEuro = oddsEuro,
       super._();

  factory _$AmFootballMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$AmFootballMatchImplFromJson(json);

  @override
  final String id;
  @override
  final int statusId;
  @override
  final String matchTimeSim;
  @override
  final String homeName;
  @override
  final String homeLogo;
  @override
  final String homeScore;
  @override
  final String awayName;
  @override
  final String awayLogo;
  @override
  final String awayScore;
  @override
  final String leagueName;
  @override
  final String leagueLogo;
  @override
  final int? matchTime;

  /// Per-quarter breakdown keyed by "p1".."p4" plus "ft" (total points).
  final Map<String, dynamic>? _scores;

  /// Per-quarter breakdown keyed by "p1".."p4" plus "ft" (total points).
  @override
  Map<String, dynamic>? get scores {
    final value = _scores;
    if (value == null) return null;
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? description;
  final List<dynamic>? _oddsEuro;
  @override
  List<dynamic>? get oddsEuro {
    final value = _oddsEuro;
    if (value == null) return null;
    if (_oddsEuro is EqualUnmodifiableListView) return _oddsEuro;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? statusDescription;

  @override
  String toString() {
    return 'AmFootballMatch(id: $id, statusId: $statusId, matchTimeSim: $matchTimeSim, homeName: $homeName, homeLogo: $homeLogo, homeScore: $homeScore, awayName: $awayName, awayLogo: $awayLogo, awayScore: $awayScore, leagueName: $leagueName, leagueLogo: $leagueLogo, matchTime: $matchTime, scores: $scores, description: $description, oddsEuro: $oddsEuro, statusDescription: $statusDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AmFootballMatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.statusId, statusId) ||
                other.statusId == statusId) &&
            (identical(other.matchTimeSim, matchTimeSim) ||
                other.matchTimeSim == matchTimeSim) &&
            (identical(other.homeName, homeName) ||
                other.homeName == homeName) &&
            (identical(other.homeLogo, homeLogo) ||
                other.homeLogo == homeLogo) &&
            (identical(other.homeScore, homeScore) ||
                other.homeScore == homeScore) &&
            (identical(other.awayName, awayName) ||
                other.awayName == awayName) &&
            (identical(other.awayLogo, awayLogo) ||
                other.awayLogo == awayLogo) &&
            (identical(other.awayScore, awayScore) ||
                other.awayScore == awayScore) &&
            (identical(other.leagueName, leagueName) ||
                other.leagueName == leagueName) &&
            (identical(other.leagueLogo, leagueLogo) ||
                other.leagueLogo == leagueLogo) &&
            (identical(other.matchTime, matchTime) ||
                other.matchTime == matchTime) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._oddsEuro, _oddsEuro) &&
            (identical(other.statusDescription, statusDescription) ||
                other.statusDescription == statusDescription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    statusId,
    matchTimeSim,
    homeName,
    homeLogo,
    homeScore,
    awayName,
    awayLogo,
    awayScore,
    leagueName,
    leagueLogo,
    matchTime,
    const DeepCollectionEquality().hash(_scores),
    description,
    const DeepCollectionEquality().hash(_oddsEuro),
    statusDescription,
  );

  /// Create a copy of AmFootballMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AmFootballMatchImplCopyWith<_$AmFootballMatchImpl> get copyWith =>
      __$$AmFootballMatchImplCopyWithImpl<_$AmFootballMatchImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AmFootballMatchImplToJson(this);
  }
}

abstract class _AmFootballMatch extends AmFootballMatch {
  const factory _AmFootballMatch({
    required final String id,
    required final int statusId,
    required final String matchTimeSim,
    required final String homeName,
    required final String homeLogo,
    required final String homeScore,
    required final String awayName,
    required final String awayLogo,
    required final String awayScore,
    required final String leagueName,
    required final String leagueLogo,
    final int? matchTime,
    final Map<String, dynamic>? scores,
    final String? description,
    final List<dynamic>? oddsEuro,
    final String? statusDescription,
  }) = _$AmFootballMatchImpl;
  const _AmFootballMatch._() : super._();

  factory _AmFootballMatch.fromJson(Map<String, dynamic> json) =
      _$AmFootballMatchImpl.fromJson;

  @override
  String get id;
  @override
  int get statusId;
  @override
  String get matchTimeSim;
  @override
  String get homeName;
  @override
  String get homeLogo;
  @override
  String get homeScore;
  @override
  String get awayName;
  @override
  String get awayLogo;
  @override
  String get awayScore;
  @override
  String get leagueName;
  @override
  String get leagueLogo;
  @override
  int? get matchTime;

  /// Per-quarter breakdown keyed by "p1".."p4" plus "ft" (total points).
  @override
  Map<String, dynamic>? get scores;
  @override
  String? get description;
  @override
  List<dynamic>? get oddsEuro;
  @override
  String? get statusDescription;

  /// Create a copy of AmFootballMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AmFootballMatchImplCopyWith<_$AmFootballMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
