import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_hashtag.freezed.dart';
part 'community_hashtag.g.dart';

@freezed
sealed class CommunityHashtag with _$CommunityHashtag {
  const factory CommunityHashtag({required String name, @Default(0) int postsCount}) = _CommunityHashtag;

  factory CommunityHashtag.fromJson(Map<String, dynamic> json) => _$CommunityHashtagFromJson(json);
}
