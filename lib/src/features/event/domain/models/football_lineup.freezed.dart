// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'football_lineup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LineupPlayer _$LineupPlayerFromJson(Map<String, dynamic> json) {
  return _LineupPlayer.fromJson(json);
}

/// @nodoc
mixin _$LineupPlayer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'cn_name')
  String? get cnName => throw _privateConstructorUsedError;
  String get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'shirt_number')
  int get shirtNumber => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  int? get x => throw _privateConstructorUsedError;
  int? get y => throw _privateConstructorUsedError;
  String get rating => throw _privateConstructorUsedError;
  int get first => throw _privateConstructorUsedError;
  int get captain => throw _privateConstructorUsedError;

  /// Serializes this LineupPlayer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineupPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineupPlayerCopyWith<LineupPlayer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineupPlayerCopyWith<$Res> {
  factory $LineupPlayerCopyWith(
    LineupPlayer value,
    $Res Function(LineupPlayer) then,
  ) = _$LineupPlayerCopyWithImpl<$Res, LineupPlayer>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'cn_name') String? cnName,
    String logo,
    @JsonKey(name: 'shirt_number') int shirtNumber,
    String position,
    int? x,
    int? y,
    String rating,
    int first,
    int captain,
  });
}

/// @nodoc
class _$LineupPlayerCopyWithImpl<$Res, $Val extends LineupPlayer>
    implements $LineupPlayerCopyWith<$Res> {
  _$LineupPlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineupPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cnName = freezed,
    Object? logo = null,
    Object? shirtNumber = null,
    Object? position = null,
    Object? x = freezed,
    Object? y = freezed,
    Object? rating = null,
    Object? first = null,
    Object? captain = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            cnName: freezed == cnName
                ? _value.cnName
                : cnName // ignore: cast_nullable_to_non_nullable
                      as String?,
            logo: null == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                      as String,
            shirtNumber: null == shirtNumber
                ? _value.shirtNumber
                : shirtNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String,
            x: freezed == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as int?,
            y: freezed == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as int?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as String,
            first: null == first
                ? _value.first
                : first // ignore: cast_nullable_to_non_nullable
                      as int,
            captain: null == captain
                ? _value.captain
                : captain // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LineupPlayerImplCopyWith<$Res>
    implements $LineupPlayerCopyWith<$Res> {
  factory _$$LineupPlayerImplCopyWith(
    _$LineupPlayerImpl value,
    $Res Function(_$LineupPlayerImpl) then,
  ) = __$$LineupPlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'cn_name') String? cnName,
    String logo,
    @JsonKey(name: 'shirt_number') int shirtNumber,
    String position,
    int? x,
    int? y,
    String rating,
    int first,
    int captain,
  });
}

/// @nodoc
class __$$LineupPlayerImplCopyWithImpl<$Res>
    extends _$LineupPlayerCopyWithImpl<$Res, _$LineupPlayerImpl>
    implements _$$LineupPlayerImplCopyWith<$Res> {
  __$$LineupPlayerImplCopyWithImpl(
    _$LineupPlayerImpl _value,
    $Res Function(_$LineupPlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LineupPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cnName = freezed,
    Object? logo = null,
    Object? shirtNumber = null,
    Object? position = null,
    Object? x = freezed,
    Object? y = freezed,
    Object? rating = null,
    Object? first = null,
    Object? captain = null,
  }) {
    return _then(
      _$LineupPlayerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        cnName: freezed == cnName
            ? _value.cnName
            : cnName // ignore: cast_nullable_to_non_nullable
                  as String?,
        logo: null == logo
            ? _value.logo
            : logo // ignore: cast_nullable_to_non_nullable
                  as String,
        shirtNumber: null == shirtNumber
            ? _value.shirtNumber
            : shirtNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String,
        x: freezed == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as int?,
        y: freezed == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as int?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as String,
        first: null == first
            ? _value.first
            : first // ignore: cast_nullable_to_non_nullable
                  as int,
        captain: null == captain
            ? _value.captain
            : captain // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LineupPlayerImpl implements _LineupPlayer {
  const _$LineupPlayerImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'cn_name') this.cnName,
    required this.logo,
    @JsonKey(name: 'shirt_number') required this.shirtNumber,
    required this.position,
    required this.x,
    required this.y,
    required this.rating,
    required this.first,
    required this.captain,
  });

  factory _$LineupPlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineupPlayerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'cn_name')
  final String? cnName;
  @override
  final String logo;
  @override
  @JsonKey(name: 'shirt_number')
  final int shirtNumber;
  @override
  final String position;
  @override
  final int? x;
  @override
  final int? y;
  @override
  final String rating;
  @override
  final int first;
  @override
  final int captain;

  @override
  String toString() {
    return 'LineupPlayer(id: $id, name: $name, cnName: $cnName, logo: $logo, shirtNumber: $shirtNumber, position: $position, x: $x, y: $y, rating: $rating, first: $first, captain: $captain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineupPlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cnName, cnName) || other.cnName == cnName) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.shirtNumber, shirtNumber) ||
                other.shirtNumber == shirtNumber) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.first, first) || other.first == first) &&
            (identical(other.captain, captain) || other.captain == captain));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    cnName,
    logo,
    shirtNumber,
    position,
    x,
    y,
    rating,
    first,
    captain,
  );

  /// Create a copy of LineupPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineupPlayerImplCopyWith<_$LineupPlayerImpl> get copyWith =>
      __$$LineupPlayerImplCopyWithImpl<_$LineupPlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineupPlayerImplToJson(this);
  }
}

abstract class _LineupPlayer implements LineupPlayer {
  const factory _LineupPlayer({
    required final String id,
    required final String name,
    @JsonKey(name: 'cn_name') final String? cnName,
    required final String logo,
    @JsonKey(name: 'shirt_number') required final int shirtNumber,
    required final String position,
    required final int? x,
    required final int? y,
    required final String rating,
    required final int first,
    required final int captain,
  }) = _$LineupPlayerImpl;

  factory _LineupPlayer.fromJson(Map<String, dynamic> json) =
      _$LineupPlayerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'cn_name')
  String? get cnName;
  @override
  String get logo;
  @override
  @JsonKey(name: 'shirt_number')
  int get shirtNumber;
  @override
  String get position;
  @override
  int? get x;
  @override
  int? get y;
  @override
  String get rating;
  @override
  int get first;
  @override
  int get captain;

  /// Create a copy of LineupPlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineupPlayerImplCopyWith<_$LineupPlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FootballLineups _$FootballLineupsFromJson(Map<String, dynamic> json) {
  return _FootballLineups.fromJson(json);
}

/// @nodoc
mixin _$FootballLineups {
  List<LineupPlayer> get home => throw _privateConstructorUsedError;
  List<LineupPlayer> get away => throw _privateConstructorUsedError;

  /// Serializes this FootballLineups to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FootballLineups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FootballLineupsCopyWith<FootballLineups> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FootballLineupsCopyWith<$Res> {
  factory $FootballLineupsCopyWith(
    FootballLineups value,
    $Res Function(FootballLineups) then,
  ) = _$FootballLineupsCopyWithImpl<$Res, FootballLineups>;
  @useResult
  $Res call({List<LineupPlayer> home, List<LineupPlayer> away});
}

/// @nodoc
class _$FootballLineupsCopyWithImpl<$Res, $Val extends FootballLineups>
    implements $FootballLineupsCopyWith<$Res> {
  _$FootballLineupsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FootballLineups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? home = null, Object? away = null}) {
    return _then(
      _value.copyWith(
            home: null == home
                ? _value.home
                : home // ignore: cast_nullable_to_non_nullable
                      as List<LineupPlayer>,
            away: null == away
                ? _value.away
                : away // ignore: cast_nullable_to_non_nullable
                      as List<LineupPlayer>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FootballLineupsImplCopyWith<$Res>
    implements $FootballLineupsCopyWith<$Res> {
  factory _$$FootballLineupsImplCopyWith(
    _$FootballLineupsImpl value,
    $Res Function(_$FootballLineupsImpl) then,
  ) = __$$FootballLineupsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LineupPlayer> home, List<LineupPlayer> away});
}

/// @nodoc
class __$$FootballLineupsImplCopyWithImpl<$Res>
    extends _$FootballLineupsCopyWithImpl<$Res, _$FootballLineupsImpl>
    implements _$$FootballLineupsImplCopyWith<$Res> {
  __$$FootballLineupsImplCopyWithImpl(
    _$FootballLineupsImpl _value,
    $Res Function(_$FootballLineupsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FootballLineups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? home = null, Object? away = null}) {
    return _then(
      _$FootballLineupsImpl(
        home: null == home
            ? _value._home
            : home // ignore: cast_nullable_to_non_nullable
                  as List<LineupPlayer>,
        away: null == away
            ? _value._away
            : away // ignore: cast_nullable_to_non_nullable
                  as List<LineupPlayer>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FootballLineupsImpl implements _FootballLineups {
  const _$FootballLineupsImpl({
    required final List<LineupPlayer> home,
    required final List<LineupPlayer> away,
  }) : _home = home,
       _away = away;

  factory _$FootballLineupsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FootballLineupsImplFromJson(json);

  final List<LineupPlayer> _home;
  @override
  List<LineupPlayer> get home {
    if (_home is EqualUnmodifiableListView) return _home;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_home);
  }

  final List<LineupPlayer> _away;
  @override
  List<LineupPlayer> get away {
    if (_away is EqualUnmodifiableListView) return _away;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_away);
  }

  @override
  String toString() {
    return 'FootballLineups(home: $home, away: $away)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FootballLineupsImpl &&
            const DeepCollectionEquality().equals(other._home, _home) &&
            const DeepCollectionEquality().equals(other._away, _away));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_home),
    const DeepCollectionEquality().hash(_away),
  );

  /// Create a copy of FootballLineups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FootballLineupsImplCopyWith<_$FootballLineupsImpl> get copyWith =>
      __$$FootballLineupsImplCopyWithImpl<_$FootballLineupsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FootballLineupsImplToJson(this);
  }
}

abstract class _FootballLineups implements FootballLineups {
  const factory _FootballLineups({
    required final List<LineupPlayer> home,
    required final List<LineupPlayer> away,
  }) = _$FootballLineupsImpl;

  factory _FootballLineups.fromJson(Map<String, dynamic> json) =
      _$FootballLineupsImpl.fromJson;

  @override
  List<LineupPlayer> get home;
  @override
  List<LineupPlayer> get away;

  /// Create a copy of FootballLineups
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FootballLineupsImplCopyWith<_$FootballLineupsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
