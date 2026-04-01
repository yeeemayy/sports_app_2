import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_client.dart';

part 'api_service.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiService(ApiServiceRef ref) => ApiClient();
