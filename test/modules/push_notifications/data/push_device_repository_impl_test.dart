import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/push_notifications/data/repositories/push_device_repository_impl.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/failures/push_device_failure.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

import '../push_notifications_fixtures.dart';
import '../push_notifications_mocks.dart';

DioException dioFailure({int? statusCode}) {
  return DioException(
    requestOptions: RequestOptions(),
    response: statusCode == null
        ? null
        : Response<void>(
            statusCode: statusCode,
            requestOptions: RequestOptions(),
          ),
  );
}

void main() {
  late MockPushDeviceRemoteDataSource remote;
  late PushDeviceRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(PushDevicePlatform.android));

  setUp(() {
    remote = MockPushDeviceRemoteDataSource();
    repository = PushDeviceRepositoryImpl(remote: remote);
  });

  void stubRegister(Future<void> Function() answer) {
    when(
      () => remote.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('registering returns ok when the API accepts the device', () async {
    stubRegister(() async {});

    final result = await repository.registerDevice(
      token: pushToken,
      platform: PushDevicePlatform.android,
    );

    expect(result, const Ok<PushDeviceFailure, void>(null));
  });

  test('registering without a response is a network failure', () async {
    stubRegister(() async => throw dioFailure());

    final result = await repository.registerDevice(
      token: pushToken,
      platform: PushDevicePlatform.android,
    );

    expect(
      result,
      const Err<PushDeviceFailure, void>(PushDeviceFailure.network),
    );
  });

  test('unregistering with an error status is unexpected', () async {
    when(() => remote.unregisterDevice(any()))
        .thenAnswer((_) async => throw dioFailure(statusCode: 500));

    final result = await repository.unregisterDevice(pushToken);

    expect(
      result,
      const Err<PushDeviceFailure, void>(PushDeviceFailure.unexpected),
    );
  });

  test('unregistering returns ok when the API removes the device', () async {
    when(() => remote.unregisterDevice(any())).thenAnswer((_) async {});

    final result = await repository.unregisterDevice(pushToken);

    expect(result, const Ok<PushDeviceFailure, void>(null));
  });
}
