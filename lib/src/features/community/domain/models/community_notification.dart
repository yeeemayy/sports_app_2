import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post.dart';

part 'community_notification.freezed.dart';
part 'community_notification.g.dart';

/// `data` is sports_forum's polymorphic notification payload — its shape
/// depends on [dataType] (e.g. `post_liked`, `comment_replied`,
/// `user_followed`), so it's kept as a raw map rather than typed fields.
@freezed
sealed class CommunityNotification with _$CommunityNotification {
  const factory CommunityNotification({
    required String id,
    required String type,
    @Default({}) Map<String, dynamic> data,
    String? readAt,
    required String createdAt,
  }) = _CommunityNotification;

  const CommunityNotification._();

  factory CommunityNotification.fromJson(Map<String, dynamic> json) =>
      _$CommunityNotificationFromJson(json);

  bool get isUnread => readAt == null;

  /// sports_forum's own notification tiles key off `data['type']`, not the
  /// top-level `type` field — mirrored here for the same rendering logic.
  String get dataType => data['type'] as String? ?? type;
  String? get actorUsername => data['actor_username'] as String?;
  String? get actorAvatar => data['actor_avatar'] as String?;
  int? get actorId => (data['actor_id'] as num?)?.toInt();
  String? get preview => data['preview'] as String?;
  int? get postId => (data['post_id'] as num?)?.toInt();
  int? get commentId => (data['comment_id'] as num?)?.toInt();
}

@freezed
sealed class CommunityNotificationListResponse with _$CommunityNotificationListResponse {
  const factory CommunityNotificationListResponse({
    required List<CommunityNotification> list,
    required CommunityPostListMeta meta,
  }) = _CommunityNotificationListResponse;

  factory CommunityNotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$CommunityNotificationListResponseFromJson(json);
}
