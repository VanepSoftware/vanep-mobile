import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/network/api_image.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';

class _MockDio extends Mock implements Dio {}

/// PNG 1x1 valido, para o decode do Flutter nao recusar os bytes.
final _png = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(Options()));

  group('ApiImage.forPath', () {
    tearDown(() => GetIt.I.reset());

    void registerDio(Dio dio) => GetIt.I.registerSingleton<Dio>(
      dio,
      instanceName: authenticatedDioName,
    );

    test('usa o Dio autenticado do container', () {
      final dio = _MockDio();
      registerDio(dio);

      final provider = ApiImage.forPath('/api/drivers/tok1/photo')! as ApiImage;

      expect(provider.path, '/api/drivers/tok1/photo');
      expect(identical(provider.dio, dio), isTrue);
    });

    test('sem foto nao ha provider', () {
      registerDio(_MockDio());

      expect(ApiImage.forPath(null), isNull);
      expect(ApiImage.forPath(''), isNull);
    });

    test('sem Dio registrado cai no placeholder em vez de tentar sem token', () {
      expect(ApiImage.forPath('/api/drivers/tok1/photo'), isNull);
    });
  });

  group('ApiImage', () {
    test('baixa pelo Dio, que resolve o caminho relativo e poe o bearer', () async {
      final dio = _MockDio();
      when(
        () => dio.get<List<int>>(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: _png,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/drivers/tok1/photo'),
        ),
      );

      final provider = ApiImage('/api/drivers/tok1/photo', dio: dio);
      final stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      Object? failure;
      stream.addListener(
        ImageStreamListener(
          (_, _) => completer.complete(),
          onError: (error, _) {
            failure = error;
            completer.complete();
          },
        ),
      );
      await completer.future;

      expect(failure, isNull);
      final captured = verify(
        () => dio.get<List<int>>(captureAny(), options: captureAny(named: 'options')),
      ).captured;
      expect(captured[0], '/api/drivers/tok1/photo');
      expect((captured[1] as Options).responseType, ResponseType.bytes);
    });

    test('providers do mesmo caminho sao iguais, para o cache funcionar', () {
      final dio = _MockDio();

      expect(
        ApiImage('/api/clients/c1/photo', dio: dio),
        ApiImage('/api/clients/c1/photo', dio: dio),
      );
      expect(
        ApiImage('/api/clients/c1/photo', dio: dio),
        isNot(ApiImage('/api/clients/c2/photo', dio: dio)),
      );
    });
  });
}
