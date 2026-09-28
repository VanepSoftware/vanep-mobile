import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/personal_address_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/personal_address_dto.dart';
import 'package:vanep_mobile/modules/auth/data/repositories/personal_address_repository_impl.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';

import '../../personal_address_fixture.dart';
import '../auth_data_mocks.dart';

class MockPersonalAddressRemoteDataSource extends Mock
    implements PersonalAddressRemoteDataSource {}

DioException personalAddressHttpFailure({
  int? statusCode,
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/user/me/address'),
    type: statusCode == null ? DioExceptionType.connectionTimeout : type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/user/me/address'),
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  late MockPersonalAddressRemoteDataSource remote;
  late PersonalAddressRepositoryImpl repository;

  setUpAll(registerAuthDataFallbacks);

  setUp(() {
    remote = MockPersonalAddressRemoteDataSource();
    repository = PersonalAddressRepositoryImpl(remote: remote);
  });

  test('GET 200 returns the mapped address', () async {
    when(remote.fetchMyAddress).thenAnswer(
      (_) async => PersonalAddressDto.fromJson(fakePersonalAddressJson()),
    );

    final result = await repository.findMyAddress();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, fakePersonalAddress());
  });

  test('GET 404 is Ok(null), not Err', () async {
    when(
      remote.fetchMyAddress,
    ).thenThrow(personalAddressHttpFailure(statusCode: 404));

    final result = await repository.findMyAddress();

    expect(result.isOk, isTrue);
    expect(result.isErr, isFalse);
    expect(result.valueOrNull, isNull);
  });

  test('GET 500 is Err', () async {
    when(
      remote.fetchMyAddress,
    ).thenThrow(personalAddressHttpFailure(statusCode: 500));

    final result = await repository.findMyAddress();

    expect(result.isErr, isTrue);
    expect(result.errorOrNull, PersonalAddressFailure.unexpected);
  });

  test('PUT 200 applies the response DTO', () async {
    when(() => remote.upsertMyAddress(any())).thenAnswer(
      (_) async => PersonalAddressDto.fromJson(
        fakePersonalAddressJson(street: 'SQN 108'),
      ),
    );

    final result = await repository.upsertMyAddress(fakePersonalAddressWrite());

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, fakePersonalAddress(street: 'SQN 108'));
  });

  test('PUT 404 is cityNotFound', () async {
    when(
      () => remote.upsertMyAddress(any()),
    ).thenThrow(personalAddressHttpFailure(statusCode: 404));

    final result = await repository.upsertMyAddress(fakePersonalAddressWrite());

    expect(result.errorOrNull, PersonalAddressFailure.cityNotFound);
  });

  test('PUT 400 with the generic Spring problem is validation', () async {
    when(() => remote.upsertMyAddress(any())).thenThrow(
      personalAddressHttpFailure(
        statusCode: 400,
        data: fakeAddressValidationProblem(),
      ),
    );

    final result = await repository.upsertMyAddress(fakePersonalAddressWrite());

    expect(result.errorOrNull, PersonalAddressFailure.validation);
  });

  test('PUT 400 without a body is still validation', () async {
    when(
      () => remote.upsertMyAddress(any()),
    ).thenThrow(personalAddressHttpFailure(statusCode: 400));

    final result = await repository.upsertMyAddress(fakePersonalAddressWrite());

    expect(result.errorOrNull, PersonalAddressFailure.validation);
  });

  test('a timeout is network', () async {
    when(() => remote.upsertMyAddress(any())).thenThrow(
      personalAddressHttpFailure(type: DioExceptionType.connectionTimeout),
    );

    final result = await repository.upsertMyAddress(fakePersonalAddressWrite());

    expect(result.errorOrNull, PersonalAddressFailure.network);
  });

  test('DELETE 204 is Ok(null)', () async {
    when(remote.deleteMyAddress).thenAnswer((_) async {});

    final result = await repository.deleteMyAddress();

    expect(result.isOk, isTrue);
    verify(remote.deleteMyAddress).called(1);
  });

  test('DELETE timeout is network', () async {
    when(remote.deleteMyAddress).thenThrow(
      personalAddressHttpFailure(type: DioExceptionType.connectionTimeout),
    );

    final result = await repository.deleteMyAddress();

    expect(result.errorOrNull, PersonalAddressFailure.network);
  });
}
