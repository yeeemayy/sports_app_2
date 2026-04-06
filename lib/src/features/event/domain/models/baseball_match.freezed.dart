// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baseball_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BaseballMatch _$BaseballMatchFromJson(Map<String, dynamic> json) {
  return _BaseballMatch.fromJson(json);
}

/// @nodoc
mixin _$BaseballMatch {
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

  /// Per-inning breakdown keyed by "p1".."p9", plus "ft", "h", "e".
  Map<String, dynamic>? get scores => throw _privateConstructorUsedError;
  String? get statusDescriptionShort => throw _privateConstructorUsedError;
  List<dynamic>? get oddsEuro => throw _privateConstructorUsedError;
  String? get statusDescription => throw _privateConstructorUsedError;

  /// Serializes this BaseballMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseballMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseballMatchCopyWith<BaseballMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseballMatchCopyWith<$Res> {
  factory $BaseballMatchCopyWith(
    BaseballMatch value,
    $Res Function(BaseballMatch) then,
  ) = _$BaseballMatchCopyWithImpl<$Res, BaseballMatch>;
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
    String? statusDescriptionShort,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class _$BaseballMatchCopyWithImpl<$Res, $Val extends BaseballMatch>
    implements $BaseballMatchCopyWith<$Res> {
  _$BaseballMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseballMatch
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
    Object? statusDescriptionShort = freezed,
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
            statusDescriptionShort: freezed == statusDescriptionShort
                ? _value.statusDescriptionShort
                : statusDescriptionShort // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BaseballMatchImplCopyWith<$Res>
    implements $BaseballMatchCopyWith<$Res> {
  factory _$$BaseballMatchImplCopyWith(
    _$BaseballMatchImpl value,
    $Res Function(_$BaseballMatchImpl) then,
  ) = __$$BaseballMatchImplCopyWithImpl<$Res>;
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
    String? statusDescriptionShort,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class __$$BaseballMatchImplCopyWithImpl<$Res>
    extends _$BaseballMatchCopyWithImpl<$Res, _$BaseballMatchImpl>
    implements _$$BaseballMatchImplCopyWith<$Res> {
  __$$BaseballMatchImplCopyWithImpl(
    _$BaseballMatchImpl _value,
    $Res Function(_$BaseballMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseballMatch
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
    Object? statusDescriptionShort = freezed,
    Object? oddsEuro = freezed,
    Object? statusDescription = freezed,
  }) {
    return _then(
      _$BaseballMatchImpl(
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
        statusDescriptionShort: freezed == statusDescriptionShort
            ? _value.statusDescriptionShort
            : statusDescriptionShort // ignore: cast_nullable_to_non_nullable
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
class _$BaseballMatchImpl extends _BaseballMatch {
  const _$BaseballMatchImpl({
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
    this.statusDescriptionShort,
    final List<dynamic>? oddsEuro,
    this.statusDescription,
  }) : _scores = scores,
       _oddsEuro = oddsEuro,
       super._();

  factory _$BaseballMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseballMatchImplFromJson(json);

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

  /// Per-inning breakdown keyed by "p1".."p9", plus "ft", "h", "e".
  final Map<String, dynamic>? _scores;

  /// Per-inning breakdown keyed by "p1".."p9", plus "ft", "h", "e".
  @override
  Map<String, dynamic>? get scores {
    final value = _scores;
    if (value == null) return null;
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? statusDescriptionShort;
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
    return 'BaseballMatch(id: $id, statusId: $statusId, matchTimeSim: $matchTimeSim, homeName: $homeName, homeLogo: $homeLogo, homeScore: $homeScore, awayName: $awayName, awayLogo: $awayLogo, awayScore: $awayScore, leagueName: $leagueName, leagueLogo: $leagueLogo, matchTime: $matchTime, scores: $scores, statusDescriptionShort: $statusDescriptionShort, oddsEuro: $oddsEuro, statusDescription: $statusDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseballMatchImpl &&
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
            (identical(other.statusDescriptionShort, statusDescriptionShort) ||
                other.statusDescriptionShort == statusDescriptionShort) &&
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
    statusDescriptionShort,
    const DeepCollectionEquality().hash(_oddsEuro),
    statusDescription,
  );

  /// Create a copy of BaseballMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseballMatchImplCopyWith<_$BaseballMatchImpl> get copyWith =>
      __$$BaseballMatchImplCopyWithImpl<_$BaseballMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseballMatchImplToJson(this);
  }
}

abstract class _BaseballMatch extends BaseballMatch {
  const factory _BaseballMatch({
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
    final String? statusDescriptionShort,
    final List<dynamic>? oddsEuro,
    final String? statusDescription,
  }) = _$BaseballMatchImpl;
  const _BaseballMatch._() : super._();

  factory _BaseballMatch.fromJson(Map<String, dynamic> json) =
      _$BaseballMatchImpl.fromJson;

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

  /// Per-inning breakdown keyed by "p1".."p9", plus "ft", "h", "e".
  @override
  Map<String, dynamic>? get scores;
  @override
  String? get statusDescriptionShort;
  @override
  List<dynamic>? get oddsEuro;
  @override
  String? get statusDescription;

  /// Create a copy of BaseballMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseballMatchImplCopyWith<_$BaseballMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
