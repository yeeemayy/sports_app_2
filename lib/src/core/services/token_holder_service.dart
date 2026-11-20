import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/api_client.dart';

part 'token_holder_service.g.dart';

/// Holds the sports_forum session token (populated by `AuthNotifier`) — used
/// by `forumApiServiceProvider`. zb v5 requests (`apiServiceProvider`,
/// `ApiClient`) carry no user auth at all, so there is no zb equivalent —
/// see `ApiClient`'s doc comment.
@Riverpod(keepAlive: true)
TokenHolder tokenHolder(TokenHolderRef ref) => TokenHolder();
