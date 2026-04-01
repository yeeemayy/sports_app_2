// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anchor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnchorModel _$AnchorModelFromJson(Map<String, dynamic> json) {
  return _AnchorModel.fromJson(json);
}

/// @nodoc
mixin _$AnchorModel {
  int get id => throw _privateConstructorUsedError;
  int get isLive => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get notice => throw _privateConstructorUsedError;
  int get liveMode => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get collect => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'collect_status')
  int get collectStatus => throw _privateConstructorUsedError;
  String get cover => throw _privateConstructorUsedError;

  /// Serializes this AnchorModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnchorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnchorModelCopyWith<AnchorModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnchorModelCopyWith<$Res> {
  factory $AnchorModelCopyWith(
    AnchorModel value,
    $Res Function(AnchorModel) then,
  ) = _$AnchorModelCopyWithImpl<$Res, AnchorModel>;
  @useResult
  $Res call({
    int id,
    int isLive,
    String title,
    String notice,
    int liveMode,
    String nickname,
    int collect,
    String avatarUrl,
    @JsonKey(name: 'collect_status') int collectStatus,
    String cover,
  });
}

/// @nodoc
class _$AnchorModelCopyWithImpl<$Res, $Val extends AnchorModel>
    implements $AnchorModelCopyWith<$Res> {
  _$AnchorModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnchorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? title = null,
    Object? notice = null,
    Object? liveMode = null,
    Object? nickname = null,
    Object? collect = null,
    Object? avatarUrl = null,
    Object? collectStatus = null,
    Object? cover = null,
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
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            notice: null == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String,
            liveMode: null == liveMode
                ? _value.liveMode
                : liveMode // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            collect: null == collect
                ? _value.collect
                : collect // ignore: cast_nullable_to_non_nullable
                      as int,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            collectStatus: null == collectStatus
                ? _value.collectStatus
                : collectStatus // ignore: cast_nullable_to_non_nullable
                      as int,
            cover: null == cover
                ? _value.cover
                : cover // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnchorModelImplCopyWith<$Res>
    implements $AnchorModelCopyWith<$Res> {
  factory _$$AnchorModelImplCopyWith(
    _$AnchorModelImpl value,
    $Res Function(_$AnchorModelImpl) then,
  ) = __$$AnchorModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int isLive,
    String title,
    String notice,
    int liveMode,
    String nickname,
    int collect,
    String avatarUrl,
    @JsonKey(name: 'collect_status') int collectStatus,
    String cover,
  });
}

/// @nodoc
class __$$AnchorModelImplCopyWithImpl<$Res>
    extends _$AnchorModelCopyWithImpl<$Res, _$AnchorModelImpl>
    implements _$$AnchorModelImplCopyWith<$Res> {
  __$$AnchorModelImplCopyWithImpl(
    _$AnchorModelImpl _value,
    $Res Function(_$AnchorModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnchorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? title = null,
    Object? notice = null,
    Object? liveMode = null,
    Object? nickname = null,
    Object? collect = null,
    Object? avatarUrl = null,
    Object? collectStatus = null,
    Object? cover = null,
  }) {
    return _then(
      _$AnchorModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        isLive: null == isLive
            ? _value.isLive
            : isLive // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        notice: null == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String,
        liveMode: null == liveMode
            ? _value.liveMode
            : liveMode // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        collect: null == collect
            ? _value.collect
            : collect // ignore: cast_nullable_to_non_nullable
                  as int,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        collectStatus: null == collectStatus
            ? _value.collectStatus
            : collectStatus // ignore: cast_nullable_to_non_nullable
                  as int,
        cover: null == cover
            ? _value.cover
            : cover // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnchorModelImpl implements _AnchorModel {
  const _$AnchorModelImpl({
    required this.id,
    required this.isLive,
    required this.title,
    required this.notice,
    required this.liveMode,
    required this.nickname,
    required this.collect,
    required this.avatarUrl,
    @JsonKey(name: 'collect_status') required this.collectStatus,
    required this.cover,
  });

  factory _$AnchorModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnchorModelImplFromJson(json);

  @override
  final int id;
  @override
  final int isLive;
  @override
  final String title;
  @override
  final String notice;
  @override
  final int liveMode;
  @override
  final String nickname;
  @override
  final int collect;
  @override
  final String avatarUrl;
  @override
  @JsonKey(name: 'collect_status')
  final int collectStatus;
  @override
  final String cover;

  @override
  String toString() {
    return 'AnchorModel(id: $id, isLive: $isLive, title: $title, notice: $notice, liveMode: $liveMode, nickname: $nickname, collect: $collect, avatarUrl: $avatarUrl, collectStatus: $collectStatus, cover: $cover)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnchorModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isLive, isLive) || other.isLive == isLive) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notice, notice) || other.notice == notice) &&
            (identical(other.liveMode, liveMode) ||
                other.liveMode == liveMode) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.collect, collect) || other.collect == collect) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.collectStatus, collectStatus) ||
                other.collectStatus == collectStatus) &&
            (identical(other.cover, cover) || other.cover == cover));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    isLive,
    title,
    notice,
    liveMode,
    nickname,
    collect,
    avatarUrl,
    collectStatus,
    cover,
  );

  /// Create a copy of AnchorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnchorModelImplCopyWith<_$AnchorModelImpl> get copyWith =>
      __$$AnchorModelImplCopyWithImpl<_$AnchorModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnchorModelImplToJson(this);
  }
}

abstract class _AnchorModel implements AnchorModel {
  const factory _AnchorModel({
    required final int id,
    required final int isLive,
    required final String title,
    required final String notice,
    required final int liveMode,
    required final String nickname,
    required final int collect,
    required final String avatarUrl,
    @JsonKey(name: 'collect_status') required final int collectStatus,
    required final String cover,
  }) = _$AnchorModelImpl;

  factory _AnchorModel.fromJson(Map<String, dynamic> json) =
      _$AnchorModelImpl.fromJson;

  @override
  int get id;
  @override
  int get isLive;
  @override
  String get title;
  @override
  String get notice;
  @override
  int get liveMode;
  @override
  String get nickname;
  @override
  int get collect;
  @override
  String get avatarUrl;
  @override
  @JsonKey(name: 'collect_status')
  int get collectStatus;
  @override
  String get cover;

  /// Create a copy of AnchorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnchorModelImplCopyWith<_$AnchorModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
