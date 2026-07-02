import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/api_client.dart';

part 'token_holder_service.g.dart';

@Riverpod(keepAlive: true)
TokenHolder tokenHolder(TokenHolderRef ref) => TokenHolder();
