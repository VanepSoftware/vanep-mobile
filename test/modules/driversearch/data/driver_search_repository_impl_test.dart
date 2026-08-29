import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driversearch/data/datasources/driver_search_remote_datasource.dart';
import 'package:vanep_mobile/modules/driversearch/data/repositories/driver_search_repository_impl.dart';
import 'package:vanep_mobile/modules/driversearch/domain/failures/driver_search_failure.dart';

class MockDriverSearchRemoteDataSource extends Mock
    implements DriverSearchRemoteDataSource {}

DioException dioFailure(int? statusCode) {
  return DioException(
    requestOptions: RequestOptions(),
    response: statusCode == null
        ? null
        : Response<void>(statusCode: statusCode, requestOptions: RequestOptions()),
  );
}

const rankedPage = <String, dynamic>{
  'last': true,
  'content': [
    {'token': 'driver-qnl5', 'name': 'Mais específico'},
    {'token': 'driver-taguatinga', 'name': 'Intermediário'},
    {'token': 'driver-cidade', 'name': 'Cidade inteira'},
  ],
};

void main() {
  late MockDriverSearchRemoteDataSource remote;
  late DriverSearchRepositoryImpl repository;

  setUp(() {
    remote = MockDriverSearchRemoteDataSource();
    repository = DriverSearchRepositoryImpl(remote: remote);
  });

  /// O ranking é do backend. Reordenar aqui desfaria a ordem por especificidade
  /// e faria a lista mentir sobre quem atende mais de perto.
  test('preserves the order returned by the API', () async {
    when(() => remote.searchByPlace(any(), any())).thenAnswer(
      (_) async => readSearchPage(rankedPage),
    );

    final result = await repository.searchByPlace('place-qnl5', null);

    expect(
      result.valueOrNull?.drivers.map((driver) => driver.token).toList(),
      ['driver-qnl5', 'driver-taguatinga', 'driver-cidade'],
    );
  });

  test('reports whether there are more pages to load', () {
    expect(readSearchPage(const {'content': <Object?>[], 'last': false}).isLast, isFalse);
    expect(readSearchPage(const {'content': <Object?>[], 'last': true}).isLast, isTrue);
  });

  test('an empty page is an empty result, not a failure', () async {
    when(() => remote.searchByPlace(any(), any()))
        .thenAnswer((_) async => readSearchPage(const {'content': <Object?>[]}));

    final result = await repository.searchByPlace('place-qnl5', null);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.drivers, isEmpty);
  });

  test('a rejected place is distinct from a rate limit', () async {
    when(() => remote.searchByPlace(any(), any())).thenThrow(dioFailure(400));

    final result = await repository.searchByPlace('lixo', null);

    expect(result.errorOrNull, DriverSearchFailure.placeNotResolved);
  });

  test('a rate limit has its own failure', () async {
    when(() => remote.searchByPlace(any(), any())).thenThrow(dioFailure(429));

    final result = await repository.searchByPlace('place-qnl5', null);

    expect(result.errorOrNull, DriverSearchFailure.rateLimited);
  });

  test('no response is a network failure', () async {
    when(() => remote.searchByPlace(any(), any())).thenThrow(dioFailure(null));

    final result = await repository.searchByPlace('place-qnl5', null);

    expect(result.errorOrNull, DriverSearchFailure.network);
  });

  test('any other status is unexpected', () async {
    when(() => remote.searchByPlace(any(), any())).thenThrow(dioFailure(500));

    final result = await repository.searchByPlace('place-qnl5', null);

    expect(result.errorOrNull, DriverSearchFailure.unexpected);
  });

  test('maps every driver field the API returns', () {
    final drivers = readSearchPage(const {
      'content': [
        {
          'token': 'driver-1',
          'name': 'Fabio',
          'photo': 'photo.png',
          'rating': 4.5,
          'basePrice': 75.0,
          'experienceYears': 8,
          'available': true,
        },
      ],
    });

    final driver = drivers.drivers.single;
    expect(driver.name, 'Fabio');
    expect(driver.photoUrl, 'photo.png');
    expect(driver.rating, 4.5);
    expect(driver.basePrice, 75.0);
    expect(driver.experienceYears, 8);
    expect(driver.available, isTrue);
  });

  /// Privacidade: a resposta da busca não carrega endereço residencial, e a
  /// entidade não tem onde guardar caso o backend um dia mande.
  test('the entity has no residential address field', () {
    final drivers = readSearchPage(const {
      'content': [
        {'token': 'driver-1', 'name': 'Fabio', 'street': 'Rua X', 'zipCode': '70000000'},
      ],
    });

    expect(drivers.drivers.single.props, isNot(contains('Rua X')));
    expect(drivers.drivers.single.props, isNot(contains('70000000')));
  });
}
