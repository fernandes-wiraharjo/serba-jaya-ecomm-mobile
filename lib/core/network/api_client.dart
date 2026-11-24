import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';

/// Gunakan di Options.extra untuk operasi yang membutuhkan sesi aplikasi.
const requiresSession = 'requiresSession';

Dio createApiClient({
  required Uri? baseUrl,
  required String? Function() accessToken,
  bool debugLogging = false,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl?.toString() ?? '',
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: false,
      receiveDataWhenStatusError: false,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.removeWhere(
          (name, _) => name.toLowerCase() == 'authorization',
        );
        options.followRedirects = false;
        final target = options.uri;
        if (baseUrl == null || !_isBackendTarget(baseUrl, target)) {
          return handler.reject(
            _localFailure(options, FailureKind.apiDisabled),
          );
        }
        if (options.extra[requiresSession] == true) {
          final token = accessToken();
          if (token == null || token.isEmpty) {
            return handler.reject(
              _localFailure(options, FailureKind.unauthorized),
            );
          }
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode && debugLogging) {
          debugPrint('API status: ${response.statusCode}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode && debugLogging) {
          debugPrint('API error: ${error.type.name}');
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}

bool _isBackendTarget(Uri base, Uri target) =>
    target.scheme == 'https' &&
    target.userInfo.isEmpty &&
    target.origin == base.origin &&
    !target.pathSegments.any(
      (segment) =>
          segment == '..' || segment.contains('/') || segment.contains('\\'),
    ) &&
    target.normalizePath().path.startsWith(base.path);

DioException _localFailure(RequestOptions request, FailureKind kind) =>
    DioException(requestOptions: request, error: AppFailure(kind));
