import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/auth_local_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_session_dto.dart';

import '../auth_data_mocks.dart';

void main() {
  late MockBox box;
  late AuthLocalDataSource local;

  setUp(() {
    box = MockBox();
    local = AuthLocalDataSource(box);
  });

  test('saveSession stores the session as an encoded JSON string', () async {
    when(() => box.put(any(), any())).thenAnswer((_) => Future<void>.value());
    final session = testAuthSessionDto();

    await local.saveSession(session);

    final captured =
        verify(() => box.put('session', captureAny())).captured.single as String;
    final decoded = jsonDecode(captured) as Map<String, dynamic>;
    expect(AuthSessionDto.fromJson(decoded), session);
  });

  test('readSession decodes the stored JSON back into a session', () {
    final session = testAuthSessionDto();
    when(() => box.get('session')).thenReturn(jsonEncode(session.toJson()));

    expect(local.readSession(), session);
  });

  test('readSession returns null when nothing is stored', () {
    when(() => box.get('session')).thenReturn(null);

    expect(local.readSession(), isNull);
  });

  test('readSession returns null on a corrupt payload', () {
    when(() => box.get('session')).thenReturn('not-json');

    expect(local.readSession(), isNull);
  });

  test('clearSession removes the stored session', () async {
    when(() => box.delete(any())).thenAnswer((_) => Future<void>.value());

    await local.clearSession();

    verify(() => box.delete('session')).called(1);
  });
}
