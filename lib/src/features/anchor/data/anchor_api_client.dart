import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/config/env_config.dart';
import 'package:shenghaotiyu/src/core/services/api_service.dart';
import 'package:shenghaotiyu/src/features/anchor/domain/models/anchor_detail_model.dart';
import 'package:shenghaotiyu/src/features/anchor/domain/models/im_token_model.dart';

part 'anchor_api_client.g.dart';

/// Client for the anchor-related endpoints (`{code, msg, data}` envelope).
/// Signed-in chat auth comes from the unified sports_forum login (see
/// `rongcloud_service.dart`); `fetchImToken` covers the guest fallback.
class AnchorApiClient {
  AnchorApiClient(this._dio);

  final Dio _dio;

  Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    if (json['code'] != 1) throw Exception(json['msg'] ?? 'API error');
    return json['data'] as Map<String, dynamic>;
  }

  Future<AnchorDetailModel> fetchAnchorDetail(int anchorId) async {
    final response = await _dio.get(
      '/anchor/$anchorId',
      queryParameters: {'appid': EnvConfig.appId},
    );
    return AnchorDetailModel.fromJson(
      _unwrap(response.data as Map<String, dynamic>),
    );
  }

  Future<ImTokenModel> fetchImToken(int cid) async {
    final response = await _dio.get('/auth/im', queryParameters: {'cid': cid});
    return ImTokenModel.fromJson(_unwrap(response.data as Map<String, dynamic>));
  }
}

@Riverpod(keepAlive: true)
AnchorApiClient anchorApiClient(AnchorApiClientRef ref) {
  return AnchorApiClient(ref.watch(apiServiceProvider).httpClient);
}
