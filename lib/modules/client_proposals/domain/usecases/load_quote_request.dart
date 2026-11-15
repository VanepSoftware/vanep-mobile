import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class LoadQuoteStudents {
  const LoadQuoteStudents({
    required this.findMyDependents,
    required this.findReadiness,
    required this.findSchoolDays,
  });

  final FindMyDependents findMyDependents;

  final FindContractReadiness findReadiness;

  final FindSchoolDays findSchoolDays;

  Future<Result<ClientProposalsFailure, QuoteStudents>> call() async {
    final dependentsResult = await findMyDependents();
    final dependents = dependentsResult.valueOrNull;
    if (dependents == null) {
      return Err(clientProposalsFailureFrom(dependentsResult.errorOrNull!));
    }
    final (readinessResult, weekResults) = await (
      findReadiness([for (final dependent in dependents) dependent.token]),
      Future.wait([
        for (final dependent in dependents) findSchoolDays(dependent.token),
      ]),
    ).wait;
    final failure =
        readinessResult.errorOrNull ??
        weekResults.map((week) => week.errorOrNull).nonNulls.firstOrNull;
    if (failure != null) return Err(clientProposalsFailureFrom(failure));
    final readiness = readinessResult.valueOrNull!;
    return Ok(
      QuoteStudents(
        students: [
          for (final (index, dependent) in dependents.indexed)
            QuoteStudent(
              dependent: dependent,
              week: weekResults[index].valueOrNull!,
              gaps: readiness.gapsOfDependent(dependent.token),
            ),
        ],
        clientGaps: clientGapsOf(readiness),
      ),
    );
  }
}

class LoadQuoteRequest {
  const LoadQuoteRequest({
    required this.findDriverProfile,
    required this.loadQuoteStudents,
    required this.listServiceRequests,
  });

  final FindDriverProfile findDriverProfile;

  final LoadQuoteStudents loadQuoteStudents;

  final ListClientServiceRequests listServiceRequests;

  Future<Result<ClientProposalsFailure, QuoteRequestSetup>> call(
    String driverToken,
  ) async {
    final (driverResult, studentsResult, openResult) = await (
      findDriverProfile(driverToken),
      loadQuoteStudents(),
      listServiceRequests(statuses: openServiceRequestStatuses),
    ).wait;
    final failure =
        driverResult.errorOrNull ??
        studentsResult.errorOrNull ??
        openResult.errorOrNull;
    if (failure != null) return Err(clientProposalsFailureFrom(failure));
    return Ok(
      QuoteRequestSetup(
        driver: driverResult.valueOrNull!,
        students: studentsResult.valueOrNull!,
        openRequests: openResult.valueOrNull!.items,
      ),
    );
  }
}
