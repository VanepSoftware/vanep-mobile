import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

final testAssistantInvite = AssistantInvite(
  token: 'invite-tok-12345678901234567890',
  driverName: 'João Motorista',
  driverPhoto: 'https://example.com/driver.png',
  driverRating: 4.9,
  vehicleDescription: 'Mercedes Sprinter 2024 (ABC-1234)',
  expiresAt: DateTime.utc(2026, 9, 20, 12, 0),
  status: 'PENDING',
);

const testAssistantVanPrimary = AssistantVan(
  token: 'van-token-primary',
  driverToken: 'driver-token-1',
  driverName: 'João Motorista',
  plate: 'ABC-1234',
  model: 'Mercedes Sprinter 2024',
  shift: 'MORNING',
);

const testAssistantVanSecondary = AssistantVan(
  token: 'van-token-secondary',
  driverToken: 'driver-token-2',
  driverName: 'Maria Motorista',
  plate: 'XYZ-9876',
  model: 'Renault Master 2023',
  shift: 'AFTERNOON',
);
