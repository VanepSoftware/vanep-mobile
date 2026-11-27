import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

const _notFoundCodes = {
  ApiErrorCodes.serviceRequestNotFound,
  ApiErrorCodes.serviceRequestDependentNotFound,
  ApiErrorCodes.serviceRequestDriverNotFound,
  ApiErrorCodes.proposalNotFound,
  ApiErrorCodes.proposalVehicleNotFound,
  ApiErrorCodes.contractNotFound,
  ApiErrorCodes.clientDriverNotFound,
  ApiErrorCodes.clientDriverClientNotFound,
  ApiErrorCodes.clientDriverDriverNotFound,
  ApiErrorCodes.dependentNotFound,
  ApiErrorCodes.clientNotFound,
  ApiErrorCodes.clientProfileNotFound,
  ApiErrorCodes.driverNotFound,
  ApiErrorCodes.userDriverProfileNotFound,
  ApiErrorCodes.requestRouteNotFound,
};

const _conflictCodes = {
  ApiErrorCodes.serviceRequestOpenExists,
  ApiErrorCodes.serviceRequestLinkHasContract,
  ApiErrorCodes.serviceRequestNotOpen,
  ApiErrorCodes.serviceRequestNotReady,
  ApiErrorCodes.proposalSentConflict,
  ApiErrorCodes.proposalAcceptStale,
  ApiErrorCodes.proposalNotCurrent,
  ApiErrorCodes.proposalRequestNotOpen,
  ApiErrorCodes.contractActiveConflict,
  ApiErrorCodes.contractStatusInvalidTransition,
  ApiErrorCodes.clientDriverAlreadyBlocked,
  ApiErrorCodes.clientDriverDuplicatePair,
  ApiErrorCodes.clientDriverNotBlocked,
  ApiErrorCodes.requestConflict,
};

const _rejectedCodes = {
  ApiErrorCodes.serviceRequestOpenLimit,
  ApiErrorCodes.serviceRequestLinkBlocked,
  ApiErrorCodes.serviceRequestDriverNotAvailable,
  ApiErrorCodes.proposalExpired,
  ApiErrorCodes.proposalItemDependentUnavailable,
  ApiErrorCodes.proposalItemsMismatch,
  ApiErrorCodes.proposalSlotsNotRequested,
  ApiErrorCodes.proposalPeriodInvalid,
  ApiErrorCodes.proposalPeriodTooLong,
  ApiErrorCodes.proposalInstallmentsBelowOneCent,
  ApiErrorCodes.proposalAdjustmentEmpty,
  ApiErrorCodes.contractLinkBlocked,
  ApiErrorCodes.contractDriverNotApproved,
  ApiErrorCodes.contractPeriodInvalid,
  ApiErrorCodes.contractPeriodTooLong,
  ApiErrorCodes.contractInstallmentsBelowOneCent,
  ApiErrorCodes.contractItemAddressRequired,
  ApiErrorCodes.contractItemDependentNotInLink,
  ApiErrorCodes.contractItemDuplicateDependent,
  ApiErrorCodes.contractItemSchoolRequired,
  ApiErrorCodes.contractItemSlotConflict,
  ApiErrorCodes.contractStatusRequiresSuccessor,
  ApiErrorCodes.driverNotApproved,
  ApiErrorCodes.clientDriverDriverNotApproved,
  ApiErrorCodes.clientDriverBlockHasContract,
  ApiErrorCodes.clientDriverUnblockNotBlocker,
  ApiErrorCodes.requestUnprocessable,
};

const _invalidCodes = {
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
  ApiErrorCodes.requestError,
  ApiErrorCodes.serviceRequestDayLegRequired,
  ApiErrorCodes.serviceRequestDayNoSchool,
  ApiErrorCodes.serviceRequestDayWeekdayDuplicate,
  ApiErrorCodes.serviceRequestItemDependentDuplicate,
  ApiErrorCodes.contractStatusRequired,
};

NegotiationFailure negotiationFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return const NegotiationNetworkFailure();

  if (problem.matchesAnyCode(_notFoundCodes)) {
    return const NegotiationNotFoundFailure();
  }
  if (problem.matchesAnyCode(_conflictCodes)) {
    return NegotiationConflictFailure(detail: problem.detailText);
  }
  if (problem.matchesAnyCode(_rejectedCodes)) {
    return NegotiationRejectedFailure(detail: problem.detailText);
  }
  if (problem.matchesAnyCode(_invalidCodes)) {
    return const NegotiationInvalidFailure();
  }

  return switch (problem.status) {
    404 => const NegotiationNotFoundFailure(),
    409 => NegotiationConflictFailure(detail: problem.detailText),
    422 => NegotiationRejectedFailure(detail: problem.detailText),
    400 => const NegotiationInvalidFailure(),
    _ => const NegotiationUnexpectedFailure(),
  };
}

Future<Result<NegotiationFailure, T>> guardNegotiationCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(negotiationFailureFrom(exception));
  } on FormatException {
    return const Err(NegotiationUnexpectedFailure());
  }
}
