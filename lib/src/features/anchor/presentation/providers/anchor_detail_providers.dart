import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/features/anchor/data/anchor_api_client.dart';
import 'package:shenghaotiyu/src/features/anchor/domain/models/anchor_detail_model.dart';

part 'anchor_detail_providers.g.dart';

@riverpod
Future<AnchorDetailModel> anchorDetail(AnchorDetailRef ref, int anchorId) {
  return ref.watch(anchorApiClientProvider).fetchAnchorDetail(anchorId);
}
