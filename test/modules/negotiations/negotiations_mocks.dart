import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/client_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/driver_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

class MockDio extends Mock implements Dio {}

class MockClientNegotiationRemoteDataSource extends Mock
    implements ClientNegotiationRemoteDataSource {}

class MockDriverNegotiationRemoteDataSource extends Mock
    implements DriverNegotiationRemoteDataSource {}

class MockClientNegotiationRepository extends Mock
    implements ClientNegotiationRepository {}

class MockDriverNegotiationRepository extends Mock
    implements DriverNegotiationRepository {}

class FakeClientServiceRequest extends Fake implements ClientServiceRequest {}

class FakeDriverServiceRequest extends Fake implements DriverServiceRequest {}

class FakeProposal extends Fake implements Proposal {}

const testNegotiationsEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

Response<T> okResponse<T>(T? body, {int status = 200}) {
  return Response<T>(
    requestOptions: RequestOptions(),
    statusCode: status,
    data: body,
  );
}

DioException dioFailure(int? status, {Object? body}) {
  final requestOptions = RequestOptions(path: '/api/clients/me');
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: requestOptions,
            statusCode: status,
            data: body,
          ),
  );
}

void registerNegotiationFallbackValues() {
  registerFallbackValue(const ServiceRequestDraft(driverToken: 'driver'));
  registerFallbackValue(const ProposalDraft(serviceRequestToken: 'request'));
  registerFallbackValue(const ProposalAdjustmentDraft());
}
