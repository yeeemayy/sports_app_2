// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cricket_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CricketMatch _$CricketMatchFromJson(Map<String, dynamic> json) {
  return _CricketMatch.fromJson(json);
}

/// @nodoc
mixin _$CricketMatch {
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
  String? get description => throw _privateConstructorUsedError;
  List<dynamic>? get oddsEuro => throw _privateConstructorUsedError;
  String? get statusDescription => throw _privateConstructorUsedError;

  /// Serializes this CricketMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CricketMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CricketMatchCopyWith<CricketMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CricketMatchCopyWith<$Res> {
  factory $CricketMatchCopyWith(
    CricketMatch value,
    $Res Function(CricketMatch) then,
  ) = _$CricketMatchCopyWithImpl<$Res, CricketMatch>;
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
    String? description,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class _$CricketMatchCopyWithImpl<$Res, $Val extends CricketMatch>
    implements $CricketMatchCopyWith<$Res> {
  _$CricketMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CricketMatch
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
abstract class _$$CricketMatchImplCopyWith<$Res>
    implements $CricketMatchCopyWith<$Res> {
  factory _$$CricketMatchImplCopyWith(
    _$CricketMatchImpl value,
    $Res Function(_$CricketMatchImpl) then,
  ) = __$$CricketMatchImplCopyWithImpl<$Res>;
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
    String? description,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  });
}

/// @nodoc
class __$$CricketMatchImplCopyWithImpl<$Res>
    extends _$CricketMatchCopyWithImpl<$Res, _$CricketMatchImpl>
    implements _$$CricketMatchImplCopyWith<$Res> {
  __$$CricketMatchImplCopyWithImpl(
    _$CricketMatchImpl _value,
    $Res Function(_$CricketMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CricketMatch
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
    Object? description = freezed,
    Object? oddsEuro = freezed,
    Object? statusDescription = freezed,
  }) {
    return _then(
      _$CricketMatchImpl(
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
class _$CricketMatchImpl extends _CricketMatch {
  const _$CricketMatchImpl({
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
    this.description,
    final List<dynamic>? oddsEuro,
    this.statusDescription,
  }) : _oddsEuro = oddsEuro,
       super._();

  factory _$CricketMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$CricketMatchImplFromJson(json);

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
    return 'CricketMatch(id: $id, statusId: $statusId, matchTimeSim: $matchTimeSim, homeName: $homeName, homeLogo: $homeLogo, homeScore: $homeScore, awayName: $awayName, awayLogo: $awayLogo, awayScore: $awayScore, leagueName: $leagueName, leagueLogo: $leagueLogo, matchTime: $matchTime, description: $description, oddsEuro: $oddsEuro, statusDescription: $statusDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CricketMatchImpl &&
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
    description,
    const DeepCollectionEquality().hash(_oddsEuro),
    statusDescription,
  );

  /// Create a copy of CricketMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CricketMatchImplCopyWith<_$CricketMatchImpl> get copyWith =>
      __$$CricketMatchImplCopyWithImpl<_$CricketMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CricketMatchImplToJson(this);
  }
}

abstract class _CricketMatch extends CricketMatch {
  const factory _CricketMatch({
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
    final String? description,
    final List<dynamic>? oddsEuro,
    final String? statusDescription,
  }) = _$CricketMatchImpl;
  const _CricketMatch._() : super._();

  factory _CricketMatch.fromJson(Map<String, dynamic> json) =
      _$CricketMatchImpl.fromJson;

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
  @override
  String? get description;
  @override
  List<dynamic>? get oddsEuro;
  @override
  String? get statusDescription;

  /// Create a copy of CricketMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CricketMatchImplCopyWith<_$CricketMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
