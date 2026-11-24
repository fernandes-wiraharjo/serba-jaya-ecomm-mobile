import 'package:dio/dio.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';

AppFailure mapNetworkFailure(DioException error) {
  final cause = error.error;
  if (cause is AppFailure) return cause;
  final status = error.response?.statusCode;
  return AppFailure(switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => FailureKind.timeout,
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => FailureKind.network,
    DioExceptionType.cancel => FailureKind.cancelled,
    DioExceptionType.badResponse => switch (status) {
      401 => FailureKind.unauthorized,
      403 => FailureKind.forbidden,
      final int code when code >= 500 && code < 600 => FailureKind.server,
      _ => FailureKind.invalidResponse,
    },
    _ when cause is FormatException => FailureKind.invalidResponse,
    _ => FailureKind.unknown,
  });
}
