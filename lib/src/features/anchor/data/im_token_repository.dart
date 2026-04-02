import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/anchor/domain/models/im_token_model.dart';

part 'im_token_repository.g.dart';

@Riverpod(keepAlive: true)
class ImTokenRepository extends _$ImTokenRepository {
  @override
  void build() {}

  Future<ImTokenModel> getImToken(int cid) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get('/auth/im', queryParameters: {'cid': cid});
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw Exception(json['msg'] ?? 'API error');
    return ImTokenModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
