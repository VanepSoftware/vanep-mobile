import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/delete_my_personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/upsert_my_personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';

import '../../auth_mocks.dart';
import '../../personal_address_fixture.dart';

void main() {
  late MockPersonalAddressRepository repository;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockPersonalAddressRepository();
  });

  test('FindMyPersonalAddress returns the address when present', () async {
    final address = fakePersonalAddress();
    when(repository.findMyAddress).thenAnswer(
      (_) async => Ok<PersonalAddressFailure, PersonalAddress?>(address),
    );

    final result = await FindMyPersonalAddress(repository)();

    expect(result.valueOrNull, address);
  });

  test('FindMyPersonalAddress returns null when none is registered', () async {
    when(repository.findMyAddress).thenAnswer(
      (_) async => const Ok<PersonalAddressFailure, PersonalAddress?>(null),
    );

    final result = await FindMyPersonalAddress(repository)();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });

  test('FindMyPersonalAddress forwards failures', () async {
    when(repository.findMyAddress).thenAnswer(
      (_) async => const Err<PersonalAddressFailure, PersonalAddress?>(
        PersonalAddressFailure.network,
      ),
    );

    final result = await FindMyPersonalAddress(repository)();

    expect(result.errorOrNull, PersonalAddressFailure.network);
  });

  test('UpsertMyPersonalAddress returns the saved address', () async {
    final address = fakePersonalAddress();
    final write = PersonalAddressWrite(
      cityToken: address.cityToken,
      street: address.street,
      zipCode: address.zipCode!,
    );
    when(() => repository.upsertMyAddress(write)).thenAnswer(
      (_) async => Ok<PersonalAddressFailure, PersonalAddress>(address),
    );

    final result = await UpsertMyPersonalAddress(repository)(write);

    expect(result.valueOrNull, address);
    verify(() => repository.upsertMyAddress(write)).called(1);
  });

  test('UpsertMyPersonalAddress forwards failures', () async {
    const write = PersonalAddressWrite(
      cityToken: 'city-unknown',
      street: 'QND 12',
      zipCode: '72120120',
    );
    when(() => repository.upsertMyAddress(any())).thenAnswer(
      (_) async => const Err<PersonalAddressFailure, PersonalAddress>(
        PersonalAddressFailure.cityNotFound,
      ),
    );

    final result = await UpsertMyPersonalAddress(repository)(write);

    expect(result.errorOrNull, PersonalAddressFailure.cityNotFound);
  });

  test('DeleteMyPersonalAddress returns empty ok', () async {
    when(
      repository.deleteMyAddress,
    ).thenAnswer((_) async => const Ok<PersonalAddressFailure, void>(null));

    final result = await DeleteMyPersonalAddress(repository)();

    expect(result.isOk, isTrue);
    verify(repository.deleteMyAddress).called(1);
  });

  test('DeleteMyPersonalAddress forwards failures', () async {
    when(repository.deleteMyAddress).thenAnswer(
      (_) async => const Err<PersonalAddressFailure, void>(
        PersonalAddressFailure.network,
      ),
    );

    final result = await DeleteMyPersonalAddress(repository)();

    expect(result.errorOrNull, PersonalAddressFailure.network);
  });
}
