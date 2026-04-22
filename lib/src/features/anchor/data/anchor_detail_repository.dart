import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/core/utils/app_info.dart';
import 'package:sports_app/src/features/anchor/domain/models/anchor_detail_model.dart';

part 'anchor_detail_repository.g.dart';

@Riverpod(keepAlive: true)
class AnchorDetailRepository extends _$AnchorDetailRepository {
  @override
  void build() {}

  Future<AnchorDetailModel> getAnchorDetail(int anchorId) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get(
      '/anchor/$anchorId',
      queryParameters: {'appid': AppInfo.packageName},
    );
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw Exception(json['msg'] ?? 'API error');
    return AnchorDetailModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
