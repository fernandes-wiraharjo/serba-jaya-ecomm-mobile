import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/core/network/api_client.dart';
import 'package:serba_jaya_mobile/core/network/network_failure.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int statusCode = 200;
  String body = '{}';

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }
}

void main() {
  final base = Uri.parse('https://api.example.test/service/');
  late RecordingAdapter adapter;

  Dio client({Uri? baseUrl, String? token}) {
    adapter = RecordingAdapter();
    final dio = createApiClient(baseUrl: baseUrl, accessToken: () => token);
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    return dio;
  }

  final protected = Options(extra: {requiresSession: true});

  test('a missing base URL blocks all IO', () async {
    await expectLater(
      client().get<Object?>('sample'),
      throwsA(
        isA<DioException>().having(
          (error) => mapNetworkFailure(error).kind,
          'kind',
          FailureKind.apiDisabled,
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
  });

  test('only a protected request receives the application token', () async {
    final dio = client(baseUrl: base, token: 'test-token');
    await dio.get<Object?>(
      'sample',
      options: Options(headers: {'authorization': 'caller-value'}),
    );
    await dio.post<Object?>(
      'sample',
      options: Options(extra: {requiresSession: true}, followRedirects: true),
      data: FormData.fromMap({'example': 'value'}),
      queryParameters: {'page': 2},
    );
    expect(adapter.requests.first.headers.containsKey('authorization'), false);
    expect(adapter.requests.last.headers['Authorization'], 'Bearer test-token');
    expect(adapter.requests.last.followRedirects, isFalse);
    expect(adapter.requests.last.uri.queryParameters['page'], '2');
  });

  test(
    'rejects protected requests without a token and blocks other targets',
    () async {
      final guest = client(baseUrl: base);
      await expectLater(
        guest.get<Object?>('sample', options: protected),
        throwsA(
          isA<DioException>().having(
            (error) => mapNetworkFailure(error).kind,
            'kind',
            FailureKind.unauthorized,
          ),
        ),
      );
      expect(adapter.requests, isEmpty);

      final signedIn = client(baseUrl: base, token: 'test-token');
      for (final target in [
        'https://outside.example.test/service/sample',
        'https://api.example.test:8443/service/sample',
        'https://api.example.test/other/sample',
        'https://api.example.test/service/%2E%2E/sample',
      ]) {
        await expectLater(
          signedIn.get<Object?>(target, options: protected),
          throwsA(isA<DioException>()),
        );
      }
      expect(adapter.requests, isEmpty);
    },
  );

  test('CancelToken stops the request before adapter IO', () async {
    final dio = client(baseUrl: base);
    final token = CancelToken()..cancel();
    await expectLater(
      dio.get<Object?>('sample', cancelToken: token),
      throwsA(
        isA<DioException>().having(
          (error) => mapNetworkFailure(error).kind,
          'kind',
          FailureKind.cancelled,
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
  });

  test(
    '401 and 503 keep their HTTP meaning when the body is not JSON',
    () async {
      final dio = client(baseUrl: base, token: 'test-token');
      adapter.body = '<html>Gateway error</html>';
      for (final entry in {
        401: FailureKind.unauthorized,
        503: FailureKind.server,
      }.entries) {
        adapter.statusCode = entry.key;
        await expectLater(
          dio.get<Object?>('sample', options: protected),
          throwsA(
            isA<DioException>()
                .having(
                  (error) => error.response?.statusCode,
                  'status',
                  entry.key,
                )
                .having(
                  (error) => mapNetworkFailure(error).kind,
                  'kind',
                  entry.value,
                ),
          ),
        );
      }
      expect(adapter.requests, hasLength(2));
    },
  );

  test('malformed successful response remains invalidResponse', () async {
    final dio = client(baseUrl: base);
    adapter.body = 'invalid JSON';
    await expectLater(
      dio.get<Object?>('sample'),
      throwsA(
        isA<DioException>().having(
          (error) => mapNetworkFailure(error).kind,
          'kind',
          FailureKind.invalidResponse,
        ),
      ),
    );
  });

  test('maps status and transport failures independently of server body', () {
    final request = RequestOptions(path: 'sample');
    for (final entry in {
      401: FailureKind.unauthorized,
      403: FailureKind.forbidden,
      503: FailureKind.server,
      418: FailureKind.invalidResponse,
    }.entries) {
      final error = DioException.badResponse(
        statusCode: entry.key,
        requestOptions: request,
        response: Response<Object?>(
          requestOptions: request,
          statusCode: entry.key,
        ),
      );
      expect(mapNetworkFailure(error).kind, entry.value);
    }
    for (final entry in {
      DioExceptionType.connectionTimeout: FailureKind.timeout,
      DioExceptionType.connectionError: FailureKind.network,
      DioExceptionType.cancel: FailureKind.cancelled,
      DioExceptionType.unknown: FailureKind.unknown,
    }.entries) {
      final error = DioException(requestOptions: request, type: entry.key);
      expect(mapNetworkFailure(error).kind, entry.value);
    }
  });
}
