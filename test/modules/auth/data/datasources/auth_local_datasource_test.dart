import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/auth_local_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_session_dto.dart';

import '../auth_data_mocks.dart';

void main() {
  late MockSecureStorage storage;
  late AuthLocalDataSource local;

  setUp(() {
    storage = MockSecureStorage();
    local = AuthLocalDataSource(storage);
  });

  test('saveSession writes the session as encoded JSON', () async {
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) => Future<void>.value());
    final session = testAuthSessionDto();

    await local.saveSession(session);

    final captured =
        verify(
              () => storage.write(
                key: AuthLocalDataSource.sessionKey,
                value: captureAny(named: 'value'),
              ),
            ).captured.single
            as String;
    final decoded = jsonDecode(captured) as Map<String, dynamic>;
    expect(AuthSessionDto.fromJson(decoded), session);
  });

  test('readSession decodes the stored JSON back into a session', () async {
    final session = testAuthSessionDto();
    when(
      () => storage.read(key: AuthLocalDataSource.sessionKey),
    ).thenAnswer((_) async => jsonEncode(session.toJson()));

    expect(await local.readSession(), session);
  });

  test('readSession returns null when nothing is stored', () async {
    when(
      () => storage.read(key: AuthLocalDataSource.sessionKey),
    ).thenAnswer((_) async => null);

    expect(await local.readSession(), isNull);
  });

  test('readSession returns null on a corrupt payload', () async {
    when(
      () => storage.read(key: AuthLocalDataSource.sessionKey),
    ).thenAnswer((_) async => 'not-json');

    expect(await local.readSession(), isNull);
  });

  test('readSession returns null when the platform store fails', () async {
    when(
      () => storage.read(key: AuthLocalDataSource.sessionKey),
    ).thenThrow(PlatformException(code: 'keystore'));

    expect(await local.readSession(), isNull);
  });

  test('clearSession deletes the stored session', () async {
    when(
      () => storage.delete(key: any(named: 'key')),
    ).thenAnswer((_) => Future<void>.value());

    await local.clearSession();

    verify(() => storage.delete(key: AuthLocalDataSource.sessionKey)).called(1);
  });
}
