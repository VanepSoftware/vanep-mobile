import 'package:dio/dio.dart';

import '../../../../core/network/problem_detail.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/repositories/dependent_repository.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../datasources/dependent_remote_datasource.dart';

const Map<String, DependentField> dependentFieldsByApiName = {
  'name': DependentField.name,
  'birthDate': DependentField.birthDate,
  'gender': DependentField.gender,
  'address': DependentField.address,
};

const cityNotFoundDetailMarkers = ['cidade', 'city'];

bool isCityNotFoundDetail(String detail) {
  final normalized = detail.toLowerCase();
  return cityNotFoundDetailMarkers.any(normalized.contains);
}

DependentFailure dependentFailureFrom(
  DioException exception, {
  bool isCreate = false,
}) {
  final status = exception.response?.statusCode;
  if (status == null) return const DependentNetworkFailure();
  final body = exception.response?.data;
  if (status == 404) {
    final isCity = isCreate || isCityNotFoundDetail(readProblemDetail(body));
    return isCity
        ? const DependentCityNotFoundFailure()
        : const DependentNotFoundFailure();
  }
  if (status != 400) return const DependentUnexpectedFailure();

  final field = dependentFieldsByApiName[readProblemField(body)];
  if (field == null) return const DependentValidationFailure();
  return DependentValidationFailure(
    messagesByField: {field: readProblemDetail(body)},
  );
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
