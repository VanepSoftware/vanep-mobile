import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/data/dtos/profile_summary_dto.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/driver_approval_status.dart';

import '../../profile_fixtures.dart';

void main() {
  test('fromJson maps client summary fields', () {
    final dto = ClientProfileSummaryDto.fromJson({
      'token': 'client-summary-1',
      'photo': 'https://cdn.example.com/photo.jpg',
      'rating': 4.5,
      'active': true,
      'user': {
        'token': 'user-token-1',
        'name': 'Alex',
        'type': 'CLIENT',
      },
    });

    expect(dto, testClientSummaryDto);
    expect(dto, isA<ClientProfileSummary>());
    expect(dto.user?.type, UserType.client);
  });

  test('fromJson maps driver summary fields', () {
    final dto = DriverProfileSummaryDto.fromJson({
      'token': 'summary-token-1',
      'photo': 'https://cdn.example.com/photo.jpg',
      'rating': 4.8,
      'city': 'São Paulo',
      'approvalStatus': 'APPROVED',
      'available': true,
      'active': true,
      'user': {
        'token': 'user-token-1',
        'name': 'Ana Motorista',
        'email': 'ana@vanep.com.br',
        'type': 'DRIVER',
      },
    });

    expect(dto, testDriverSummaryDto);
    expect(dto, isA<DriverProfileSummary>());
    expect(dto.approvalStatus, DriverApprovalStatus.approved);
  });

  test('fromJson maps assistant summary with pendingInvite', () {
    final dto = AssistantProfileSummaryDto.fromJson({
      'token': 'assistant-summary-1',
      'photo': 'https://cdn.example.com/photo.jpg',
      'status': 'PENDING',
      'pendingInvite': {
        'token': '5645ae3b2e194fa884b51cb91',
        'expiresAt': '2026-07-26T03:18:11.514738Z',
        'driver': {
          'name': 'Fabio Teixeira',
          'photo': null,
          'city': null,
          'rating': null,
        },
      },
      'user': {
        'token': 'user-token-2',
        'name': 'Assistente',
        'type': 'ASSISTANT',
      },
    });

    expect(dto, testAssistantSummaryDto);
    expect(dto, isA<AssistantProfileSummary>());
    expect(dto.status, AssistantStatus.pending);
    expect(dto.pendingInvite?.driver?.name, 'Fabio Teixeira');
  });

  test('fromJson leaves optional driver fields null when omitted', () {
    final dto = DriverProfileSummaryDto.fromJson({'token': 'summary-token-2'});

    expect(dto, testProfileSummaryWithoutPhoto);
    expect(dto.photoUrl, isNull);
    expect(dto.rating, isNull);
    expect(dto.approvalStatus, isNull);
    expect(dto.user, isNull);
  });
}
