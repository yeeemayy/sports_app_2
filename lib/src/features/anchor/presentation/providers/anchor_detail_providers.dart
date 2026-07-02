import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/features/anchor/data/anchor_detail_repository.dart';
import 'package:shenghaotiyu/src/features/anchor/domain/models/anchor_detail_model.dart';

part 'anchor_detail_providers.g.dart';

@riverpod
Future<AnchorDetailModel> anchorDetail(AnchorDetailRef ref, int anchorId) {
  return ref
      .watch(anchorDetailRepositoryProvider.notifier)
      .getAnchorDetail(anchorId);
}
