import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';

const Map<String, DependentField> dependentFieldsByApiName = {
  'name': DependentField.name,
  'birthDate': DependentField.birthDate,
  'gender': DependentField.gender,
  'address': DependentField.address,
};

const _notFoundCodes = {
  ApiErrorCodes.dependentNotFound,
  ApiErrorCodes.schoolNotFound,
  ApiErrorCodes.addressNotFound,
  ApiErrorCodes.clientNotFound,
  ApiErrorCodes.clientProfileNotFound,
  ApiErrorCodes.userAccountNotFound,
};

const _rejectedCodes = {
  ApiErrorCodes.dependentAlreadyActive,
  ApiErrorCodes.dependentOpenContract,
  ApiErrorCodes.dependentOpenNegotiation,
  ApiErrorCodes.dependentDocumentDuplicate,
  ApiErrorCodes.addressAlreadyOwned,
};

const _validationCodes = {
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
  ApiErrorCodes.dependentFieldNull,
  ApiErrorCodes.dependentNameBlank,
  ApiErrorCodes.dependentSchoolTokenBlank,
  ApiErrorCodes.dependentClientTokenRequired,
  ApiErrorCodes.dependentSchoolDaysWeekdayDuplicate,
};

DependentFailure dependentFailureFrom(
  DioException exception, {
  bool isCreate = false,
}) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return const DependentNetworkFailure();

  if (problem.matchesCode(ApiErrorCodes.cityNotFound)) {
    return const DependentCityNotFoundFailure();
  }
  if (problem.matchesAnyCode(_notFoundCodes)) {
    return isCreate
        ? const DependentCityNotFoundFailure()
        : const DependentNotFoundFailure();
  }
  if (problem.matchesAnyCode(_rejectedCodes)) {
    final detail = problem.detailText;
    return detail.isEmpty
        ? const DependentUnexpectedFailure()
        : DependentRejectedFailure(detail: detail);
  }
  if (problem.matchesAnyCode(_validationCodes)) {
    return _validationFailureFrom(problem);
  }

  return switch (problem.status) {
    404 =>
      isCreate
          ? const DependentCityNotFoundFailure()
          : const DependentNotFoundFailure(),
    409 || 422 =>
      problem.detailText.isEmpty
          ? const DependentUnexpectedFailure()
          : DependentRejectedFailure(detail: problem.detailText),
    400 => _validationFailureFrom(problem),
    _ => const DependentUnexpectedFailure(),
  };
}

DependentValidationFailure _validationFailureFrom(ApiProblem problem) {
  final byField = <DependentField, String>{};
  for (final error in problem.errors) {
    final mapped = dependentFieldsByApiName[error.field];
    final message = error.message;
    if (mapped != null && message != null && message.isNotEmpty) {
      byField[mapped] = message;
    }
  }
  if (byField.isEmpty && problem.field != null) {
    final mapped = dependentFieldsByApiName[problem.field];
    if (mapped != null) {
      byField[mapped] = problem.detailText;
    }
  }
  return DependentValidationFailure(messagesByField: byField);
}

class DependentRepositoryImpl implements DependentRepository {
  const DependentRepositoryImpl({required this.remote});

  final DependentRemoteDataSource remote;

  @override
  Future<Result<DependentFailure, List<Dependent>>> findMyDependents() {
    return guardDependentCall(remote.fetchMyDependents);
  }

  @override
  Future<Result<DependentFailure, Dependent>> createDependent(
    DependentChanges changes,
  ) {
    return guardDependentCall(
      () => remote.createDependent(changes),
      isCreate: true,
    );
  }

  @override
  Future<Result<DependentFailure, Dependent>> updateDependent({
    required String token,
    required DependentChanges changes,
  }) {
    return guardDependentCall(
      () => remote.updateDependent(token: token, changes: changes),
    );
  }

  @override
  Future<Result<DependentFailure, Dependent>> markAsDefault(String token) {
    return guardDependentCall(() => remote.markAsDefault(token));
  }

  @override
  Future<Result<DependentFailure, void>> removeDependent(String token) {
    return guardDependentCall(() => remote.removeDependent(token));
  }
}

Future<Result<DependentFailure, T>> guardDependentCall<T>(
  Future<T> Function() call, {
  bool isCreate = false,
}) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(dependentFailureFrom(exception, isCreate: isCreate));
  } on FormatException {
    return const Err(DependentUnexpectedFailure());
  }
}
