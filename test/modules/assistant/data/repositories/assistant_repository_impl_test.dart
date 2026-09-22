import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_invite_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_lean_signup_request_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_van_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

class MockAssistantRemoteDataSource extends Mock
    implements AssistantRemoteDataSource {}

DioException _dioException(int? statusCode, {Object? data}) {
  final requestOptions = RequestOptions(path: '');
  return DioException(
    requestOptions: requestOptions,
    response: statusCode != null
        ? Response<Object?>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          )
        : null,
  );
}

void main() {
  late MockAssistantRemoteDataSource remote;
  late AssistantRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const AssistantLeanSignupRequestDto(
        inviteToken: '',
        name: '',
        birthDate: '',
        email: '',
        cpf: '',
      ),
    );
  });

  setUp(() {
    remote = MockAssistantRemoteDataSource();
    repository = AssistantRepositoryImpl(remote: remote);
  });

  group('validateInvite', () {
    test('returns Ok with invite when remote call succeeds', () async {
      final dto = AssistantInviteDto(
        token: 'tok-123',
        driverName: 'Marcos',
        vehicleDescription: 'Van 2024',
        expiresAt: DateTime.utc(2026, 10, 1),
        status: 'PENDING',
      );

      when(() => remote.validateInvite('CODE-123')).thenAnswer((_) async => dto);

      final result = await repository.validateInvite('CODE-123');

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.token, 'tok-123');
    });

    test('returns Err(network) when network fails', () async {
      when(() => remote.validateInvite(any()))
          .thenThrow(_dioException(null));

      final result = await repository.validateInvite('CODE');

      expect(result.errorOrNull, AssistantFailure.network);
    });

    test('returns Err(invalidInviteCode) when status is 404', () async {
      when(() => remote.validateInvite(any()))
          .thenThrow(_dioException(404));

      final result = await repository.validateInvite('UNKNOWN');

      expect(result.errorOrNull, AssistantFailure.invalidInviteCode);
    });

    test('returns Err(expiredInvite) when error payload indicates expiry', () async {
      when(() => remote.validateInvite(any()))
          .thenThrow(_dioException(400, data: {'code': 'invite_expired'}));

      final result = await repository.validateInvite('EXPIRED');

      expect(result.errorOrNull, AssistantFailure.expiredInvite);
    });
  });

  group('registerWithInvite', () {
    test('returns Ok(null) when registration succeeds', () async {
      when(() => remote.registerWithInvite(any()))
          .thenAnswer((_) async {});

      final result = await repository.registerWithInvite(
        inviteToken: 'tok-invite',
        name: 'Carlos',
        birthDate: '1995-04-12',
        email: 'carlos@vanep.test',
        cpf: '123.456.789-00',
      );

      expect(result.isOk, isTrue);
    });

    test('returns Err(invalidPersonalData) when status is 400', () async {
      when(() => remote.registerWithInvite(any()))
          .thenThrow(_dioException(400, data: {'code': 'validation_error'}));

      final result = await repository.registerWithInvite(
        inviteToken: 'tok-invite',
        name: 'Carlos',
        birthDate: 'invalid',
        email: 'carlos@vanep.test',
        cpf: '000',
      );

      expect(result.errorOrNull, AssistantFailure.invalidPersonalData);
    });
  });

  group('getLinkedVans', () {
    test('returns Ok with list of vans when call succeeds', () async {
      const van = AssistantVanDto(
        token: 'v-1',
        driverToken: 'd-1',
        driverName: 'Marcos',
        plate: 'ABC-1234',
        model: 'Van',
      );

      when(() => remote.fetchLinkedVans()).thenAnswer((_) async => [van]);

      final result = await repository.getLinkedVans();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, hasLength(1));
    });

    test('returns Err(unauthorized) when status is 401', () async {
      when(() => remote.fetchLinkedVans()).thenThrow(_dioException(401));

      final result = await repository.getLinkedVans();

      expect(result.errorOrNull, AssistantFailure.unauthorized);
    });
  });
}
