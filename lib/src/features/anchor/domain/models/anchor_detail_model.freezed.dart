// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anchor_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnchorDetailModel _$AnchorDetailModelFromJson(Map<String, dynamic> json) {
  return _AnchorDetailModel.fromJson(json);
}

/// @nodoc
mixin _$AnchorDetailModel {
  int get id => throw _privateConstructorUsedError;
  int get isLive => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'collect_status')
  int get collectStatus => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get collect => throw _privateConstructorUsedError;
  String get notice => throw _privateConstructorUsedError;
  int get liveMode => throw _privateConstructorUsedError;
  String? get m3u8Url => throw _privateConstructorUsedError;
  String get cover => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get mode => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: <dynamic>[])
  List<dynamic> get live => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get schedule => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: false)
  bool get playAnimate => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get client => throw _privateConstructorUsedError;
  String get updated => throw _privateConstructorUsedError;

  /// Serializes this AnchorDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnchorDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnchorDetailModelCopyWith<AnchorDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnchorDetailModelCopyWith<$Res> {
  factory $AnchorDetailModelCopyWith(
    AnchorDetailModel value,
    $Res Function(AnchorDetailModel) then,
  ) = _$AnchorDetailModelCopyWithImpl<$Res, AnchorDetailModel>;
  @useResult
  $Res call({
    int id,
    int isLive,
    String nickname,
    String avatarUrl,
    @JsonKey(name: 'collect_status') int collectStatus,
    String title,
    int collect,
    String notice,
    int liveMode,
    String? m3u8Url,
    String cover,
    String matchId,
    @JsonKey(defaultValue: '') String mode,
    @JsonKey(defaultValue: <dynamic>[]) List<dynamic> live,
    @JsonKey(defaultValue: '') String schedule,
    @JsonKey(defaultValue: false) bool playAnimate,
    @JsonKey(defaultValue: '') String client,
    String updated,
  });
}

/// @nodoc
class _$AnchorDetailModelCopyWithImpl<$Res, $Val extends AnchorDetailModel>
    implements $AnchorDetailModelCopyWith<$Res> {
  _$AnchorDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnchorDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? nickname = null,
    Object? avatarUrl = null,
    Object? collectStatus = null,
    Object? title = null,
    Object? collect = null,
    Object? notice = null,
    Object? liveMode = null,
    Object? m3u8Url = freezed,
    Object? cover = null,
    Object? matchId = null,
    Object? mode = null,
    Object? live = null,
    Object? schedule = null,
    Object? playAnimate = null,
    Object? client = null,
    Object? updated = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            isLive: null == isLive
                ? _value.isLive
                : isLive // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            collectStatus: null == collectStatus
                ? _value.collectStatus
                : collectStatus // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            collect: null == collect
                ? _value.collect
                : collect // ignore: cast_nullable_to_non_nullable
                      as int,
            notice: null == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String,
            liveMode: null == liveMode
                ? _value.liveMode
                : liveMode // ignore: cast_nullable_to_non_nullable
                      as int,
            m3u8Url: freezed == m3u8Url
                ? _value.m3u8Url
                : m3u8Url // ignore: cast_nullable_to_non_nullable
                      as String?,
            cover: null == cover
                ? _value.cover
                : cover // ignore: cast_nullable_to_non_nullable
                      as String,
            matchId: null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as String,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String,
            live: null == live
                ? _value.live
                : live // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            schedule: null == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as String,
            playAnimate: null == playAnimate
                ? _value.playAnimate
                : playAnimate // ignore: cast_nullable_to_non_nullable
                      as bool,
            client: null == client
                ? _value.client
                : client // ignore: cast_nullable_to_non_nullable
                      as String,
            updated: null == updated
                ? _value.updated
                : updated // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnchorDetailModelImplCopyWith<$Res>
    implements $AnchorDetailModelCopyWith<$Res> {
  factory _$$AnchorDetailModelImplCopyWith(
    _$AnchorDetailModelImpl value,
    $Res Function(_$AnchorDetailModelImpl) then,
  ) = __$$AnchorDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int isLive,
    String nickname,
    String avatarUrl,
    @JsonKey(name: 'collect_status') int collectStatus,
    String title,
    int collect,
    String notice,
    int liveMode,
    String? m3u8Url,
    String cover,
    String matchId,
    @JsonKey(defaultValue: '') String mode,
    @JsonKey(defaultValue: <dynamic>[]) List<dynamic> live,
    @JsonKey(defaultValue: '') String schedule,
    @JsonKey(defaultValue: false) bool playAnimate,
    @JsonKey(defaultValue: '') String client,
    String updated,
  });
}

/// @nodoc
class __$$AnchorDetailModelImplCopyWithImpl<$Res>
    extends _$AnchorDetailModelCopyWithImpl<$Res, _$AnchorDetailModelImpl>
    implements _$$AnchorDetailModelImplCopyWith<$Res> {
  __$$AnchorDetailModelImplCopyWithImpl(
    _$AnchorDetailModelImpl _value,
    $Res Function(_$AnchorDetailModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnchorDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? nickname = null,
    Object? avatarUrl = null,
    Object? collectStatus = null,
    Object? title = null,
    Object? collect = null,
    Object? notice = null,
    Object? liveMode = null,
    Object? m3u8Url = freezed,
    Object? cover = null,
    Object? matchId = null,
    Object? mode = null,
    Object? live = null,
    Object? schedule = null,
    Object? playAnimate = null,
    Object? client = null,
    Object? updated = null,
  }) {
    return _then(
      _$AnchorDetailModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        isLive: null == isLive
            ? _value.isLive
            : isLive // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        collectStatus: null == collectStatus
            ? _value.collectStatus
            : collectStatus // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        collect: null == collect
            ? _value.collect
            : collect // ignore: cast_nullable_to_non_nullable
                  as int,
        notice: null == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String,
        liveMode: null == liveMode
            ? _value.liveMode
            : liveMode // ignore: cast_nullable_to_non_nullable
                  as int,
        m3u8Url: freezed == m3u8Url
            ? _value.m3u8Url
            : m3u8Url // ignore: cast_nullable_to_non_nullable
                  as String?,
        cover: null == cover
            ? _value.cover
            : cover // ignore: cast_nullable_to_non_nullable
                  as String,
        matchId: null == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as String,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String,
        live: null == live
            ? _value._live
            : live // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        schedule: null == schedule
            ? _value.schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as String,
        playAnimate: null == playAnimate
            ? _value.playAnimate
            : playAnimate // ignore: cast_nullable_to_non_nullable
                  as bool,
        client: null == client
            ? _value.client
            : client // ignore: cast_nullable_to_non_nullable
                  as String,
        updated: null == updated
            ? _value.updated
            : updated // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnchorDetailModelImpl implements _AnchorDetailModel {
  const _$AnchorDetailModelImpl({
    required this.id,
    required this.isLive,
    required this.nickname,
    required this.avatarUrl,
    @JsonKey(name: 'collect_status') required this.collectStatus,
    required this.title,
    required this.collect,
    required this.notice,
    required this.liveMode,
    this.m3u8Url,
    required this.cover,
    required this.matchId,
    @JsonKey(defaultValue: '') required this.mode,
    @JsonKey(defaultValue: <dynamic>[]) required final List<dynamic> live,
    @JsonKey(defaultValue: '') required this.schedule,
    @JsonKey(defaultValue: false) required this.playAnimate,
    @JsonKey(defaultValue: '') required this.client,
    required this.updated,
  }) : _live = live;

  factory _$AnchorDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnchorDetailModelImplFromJson(json);

  @override
  final int id;
  @override
  final int isLive;
  @override
  final String nickname;
  @override
  final String avatarUrl;
  @override
  @JsonKey(name: 'collect_status')
  final int collectStatus;
  @override
  final String title;
  @override
  final int collect;
  @override
  final String notice;
  @override
  final int liveMode;
  @override
  final String? m3u8Url;
  @override
  final String cover;
  @override
  final String matchId;
  @override
  @JsonKey(defaultValue: '')
  final String mode;
  final List<dynamic> _live;
  @override
  @JsonKey(defaultValue: <dynamic>[])
  List<dynamic> get live {
    if (_live is EqualUnmodifiableListView) return _live;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_live);
  }

  @override
  @JsonKey(defaultValue: '')
  final String schedule;
  @override
  @JsonKey(defaultValue: false)
  final bool playAnimate;
  @override
  @JsonKey(defaultValue: '')
  final String client;
  @override
  final String updated;

  @override
  String toString() {
    return 'AnchorDetailModel(id: $id, isLive: $isLive, nickname: $nickname, avatarUrl: $avatarUrl, collectStatus: $collectStatus, title: $title, collect: $collect, notice: $notice, liveMode: $liveMode, m3u8Url: $m3u8Url, cover: $cover, matchId: $matchId, mode: $mode, live: $live, schedule: $schedule, playAnimate: $playAnimate, client: $client, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnchorDetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isLive, isLive) || other.isLive == isLive) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.collectStatus, collectStatus) ||
                other.collectStatus == collectStatus) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.collect, collect) || other.collect == collect) &&
            (identical(other.notice, notice) || other.notice == notice) &&
            (identical(other.liveMode, liveMode) ||
                other.liveMode == liveMode) &&
            (identical(other.m3u8Url, m3u8Url) || other.m3u8Url == m3u8Url) &&
            (identical(other.cover, cover) || other.cover == cover) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            const DeepCollectionEquality().equals(other._live, _live) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.playAnimate, playAnimate) ||
                other.playAnimate == playAnimate) &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    isLive,
    nickname,
    avatarUrl,
    collectStatus,
    title,
    collect,
    notice,
    liveMode,
    m3u8Url,
    cover,
    matchId,
    mode,
    const DeepCollectionEquality().hash(_live),
    schedule,
    playAnimate,
    client,
    updated,
  );

  /// Create a copy of AnchorDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnchorDetailModelImplCopyWith<_$AnchorDetailModelImpl> get copyWith =>
      __$$AnchorDetailModelImplCopyWithImpl<_$AnchorDetailModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnchorDetailModelImplToJson(this);
  }
}

abstract class _AnchorDetailModel implements AnchorDetailModel {
  const factory _AnchorDetailModel({
    required final int id,
    required final int isLive,
    required final String nickname,
    required final String avatarUrl,
    @JsonKey(name: 'collect_status') required final int collectStatus,
    required final String title,
    required final int collect,
    required final String notice,
    required final int liveMode,
    final String? m3u8Url,
    required final String cover,
    required final String matchId,
    @JsonKey(defaultValue: '') required final String mode,
    @JsonKey(defaultValue: <dynamic>[]) required final List<dynamic> live,
    @JsonKey(defaultValue: '') required final String schedule,
    @JsonKey(defaultValue: false) required final bool playAnimate,
    @JsonKey(defaultValue: '') required final String client,
    required final String updated,
  }) = _$AnchorDetailModelImpl;

  factory _AnchorDetailModel.fromJson(Map<String, dynamic> json) =
      _$AnchorDetailModelImpl.fromJson;

  @override
  int get id;
  @override
  int get isLive;
  @override
  String get nickname;
  @override
  String get avatarUrl;
  @override
  @JsonKey(name: 'collect_status')
  int get collectStatus;
  @override
  String get title;
  @override
  int get collect;
  @override
  String get notice;
  @override
  int get liveMode;
  @override
  String? get m3u8Url;
  @override
  String get cover;
  @override
  String get matchId;
  @override
  @JsonKey(defaultValue: '')
  String get mode;
  @override
  @JsonKey(defaultValue: <dynamic>[])
  List<dynamic> get live;
  @override
  @JsonKey(defaultValue: '')
  String get schedule;
  @override
  @JsonKey(defaultValue: false)
  bool get playAnimate;
  @override
  @JsonKey(defaultValue: '')
  String get client;
  @override
  String get updated;

  /// Create a copy of AnchorDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnchorDetailModelImplCopyWith<_$AnchorDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
