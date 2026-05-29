import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/config/env_config.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';

part 'anchor_repository.g.dart';

@Riverpod(keepAlive: true)
class AnchorRepository extends _$AnchorRepository {
  @override
  void build() {}

  Future<PaginatedResponse<AnchorModel>> getAnchors({int page = 1}) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get(
      '/anchor',
      queryParameters: {'page': page, 'appid': EnvConfig.appId},
    );

    final json = response.data as Map<String, dynamic>;
    log('[AnchorRepository] raw response: $json');

    final code = json['code'];
    if (code != 1) {
      throw Exception('API error (code=$code): ${json['msg']}');
    }

    final dataJson = json['data'] as Map<String, dynamic>;

    if (dataJson.isEmpty) {
      return PaginatedResponse<AnchorModel>(
        total: 0,
        perPage: 0,
        currentPage: 0,
        lastPage: 1,
        data: <AnchorModel>[],
      );
    }

    return PaginatedResponse<AnchorModel>.fromJson(
      dataJson,
      (item) => AnchorModel.fromJson(item as Map<String, dynamic>),
    );
  }
}
