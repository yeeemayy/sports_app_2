import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/features/home/data/banner_repository.dart';
import 'package:shenghaotiyu/src/features/home/domain/models/banner_model.dart';

part 'banner_providers.g.dart';

@Riverpod(keepAlive: true)
Future<BannerModel> banner(BannerRef ref) {
  return ref.watch(bannerRepositoryProvider.notifier).getBanner();
}
