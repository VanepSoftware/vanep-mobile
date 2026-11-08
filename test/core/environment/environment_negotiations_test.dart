import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

void main() {
  const local = Environment(
    authBaseUrl: 'http://localhost:8080',
    oauthClientId: 'vanep-mobile',
  );

  test('the client negotiates under /api/clients/me', () {
    expect(
      local.clientServiceRequestsEndpoint,
      'http://localhost:8080/api/clients/me/service-requests',
    );
    expect(
      local.clientProposalsEndpoint,
      'http://localhost:8080/api/clients/me/proposals',
    );
  });

  test('the driver negotiates under /api/drivers/me', () {
    expect(
      local.driverServiceRequestsEndpoint,
      'http://localhost:8080/api/drivers/me/service-requests',
    );
    expect(
      local.driverProposalsEndpoint,
      'http://localhost:8080/api/drivers/me/proposals',
    );
  });
}
