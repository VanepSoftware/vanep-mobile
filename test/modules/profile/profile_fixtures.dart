import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/data/dtos/profile_summary_dto.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/driver_approval_status.dart';

const testNestedUserDto = UserProfileDto(
  token: 'user-token-1',
  name: 'Ana Motorista',
  email: 'ana@vanep.com.br',
  type: UserType.driver,
);

const testClientSummaryDto = ClientProfileSummaryDto(
  token: 'client-summary-1',
  photoUrl: 'https://cdn.example.com/photo.jpg',
  rating: 4.5,
  active: true,
  user: UserProfileDto(
    token: 'user-token-1',
    name: 'Alex',
    type: UserType.client,
  ),
);

const testDriverSummaryDto = DriverProfileSummaryDto(
  token: 'summary-token-1',
  photoUrl: 'https://cdn.example.com/photo.jpg',
  rating: 4.8,
  city: 'São Paulo',
  approvalStatus: DriverApprovalStatus.approved,
  available: true,
  active: true,
  user: testNestedUserDto,
);

const testAssistantSummaryDto = AssistantProfileSummaryDto(
  token: 'assistant-summary-1',
  photoUrl: 'https://cdn.example.com/photo.jpg',
  status: AssistantStatus.pending,
  pendingInvite: PendingInviteDto(
    token: '5645ae3b2e194fa884b51cb91',
    expiresAt: '2026-07-26T03:18:11.514738Z',
    driver: PendingInviteDriverDto(
      name: 'Fabio Teixeira',
    ),
  ),
  user: UserProfileDto(
    token: 'user-token-2',
    name: 'Assistente',
    type: UserType.assistant,
  ),
);

const testProfileSummaryDto = testDriverSummaryDto;

const testProfileSummaryWithoutPhoto = DriverProfileSummaryDto(
  token: 'summary-token-2',
);
