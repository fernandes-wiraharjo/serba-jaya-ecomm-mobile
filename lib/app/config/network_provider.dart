import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/core/network/api_client.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = createApiClient(
    baseUrl: config.apiBaseUrl,
    accessToken: () => ref.read(sessionProvider.notifier).accessToken,
    debugLogging: config.debugLogging,
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});
