import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/push_device_remote_datasource.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

import '../push_notifications_mocks.dart';

void main() {
  late MockDio dio;
  late PushDeviceRemoteDataSource datasource;

  setUp(() {
    dio = MockDio();
    datasource = PushDeviceRemoteDataSource(
      dio: dio,
      environment: const Environment(
        authBaseUrl: 'https://api.vanep.test',
        oauthClientId: 'vanep-mobile',
      ),
    );
  });

  test('registers the device with its token and platform', () async {
    when(() => dio.post<void>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(requestOptions: RequestOptions()));

    await datasource.registerDevice(
      token: 'abc:123',
      platform: PushDevicePlatform.android,
    );

    verify(
      () => dio.post<void>(
        'https://api.vanep.test/api/devices',
        data: {'token': 'abc:123', 'platform': 'android'},
      ),
    ).called(1);
  });

  test('unregisters the device by its url-encoded token', () async {
    when(() => dio.delete<void>(any()))
        .thenAnswer((_) async => Response(requestOptions: RequestOptions()));

    await datasource.unregisterDevice('abc:123');

    verify(
      () => dio.delete<void>('https://api.vanep.test/api/devices/abc%3A123'),
    ).called(1);
  });
}
