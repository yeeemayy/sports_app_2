import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/features/home/data/anchor_repository.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';

part 'anchor_providers.g.dart';

@riverpod
Future<PaginatedResponse<AnchorModel>> anchorList(AnchorListRef ref, {int page = 1}) {
  return ref.watch(anchorRepositoryProvider.notifier).getAnchors(page: page);
}
