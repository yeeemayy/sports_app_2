import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/anchor/data/im_token_repository.dart';
import 'package:sports_app/src/features/anchor/domain/models/im_token_model.dart';

part 'im_token_providers.g.dart';

@riverpod
Future<ImTokenModel> imToken(ImTokenRef ref, int cid) {
  return ref.watch(imTokenRepositoryProvider.notifier).getImToken(cid);
}
