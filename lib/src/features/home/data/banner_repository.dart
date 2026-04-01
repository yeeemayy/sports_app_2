import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/config/env_config.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/home/domain/models/banner_model.dart';

part 'banner_repository.g.dart';

@Riverpod(keepAlive: true)
class BannerRepository extends _$BannerRepository {
  @override
  void build() {}

  Future<BannerModel> getBanner() async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get('/anchor/banner', queryParameters: {'appid': EnvConfig.appId});

    final json = response.data as Map<String, dynamic>;
    debugPrint('[BannerRepository] raw response: $json');

    final code = json['code'];
    if (code != 1) {
      throw Exception('API error (code=$code): ${json['msg']}');
    }

    return BannerModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
