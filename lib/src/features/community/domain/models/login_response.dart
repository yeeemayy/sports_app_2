// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// sports_forum's `POST /login`/`POST /register` response — unlike most of
/// the forum API this isn't wrapped in a `{data: ...}` envelope. `rcKey`/
/// `rcToken` are RongCloud IM connect credentials; this port doesn't wire up
/// RongCloud, so they're only stored, never used.
@freezed
sealed class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'rc_key') required String rcKey,
    @JsonKey(name: 'rc_token') required String rcToken,
    required CommunityAuthor user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}
