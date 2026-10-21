import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';
import 'package:vanep_mobile/modules/schools/data/datasources/school_remote_datasource.dart';

SchoolFailure schoolFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == null) return const SchoolNetworkFailure();
  final detail = readProblemDetail(exception.response?.data);
  if (status >= 400 && status < 500 && detail.isNotEmpty) {
    return SchoolRejectedFailure(detail: detail);
  }
  return const SchoolUnexpectedFailure();
}

class SchoolRepositoryImpl implements SchoolRepository {
  const SchoolRepositoryImpl({required this.remote});

  final SchoolRemoteDataSource remote;

  @override
  Future<Result<SchoolFailure, School>> resolveSchool({
    required String placeId,
    required String sessionToken,
  }) async {
    try {
      return Ok(
        await remote.resolveSchool(
          placeId: placeId,
          sessionToken: sessionToken,
        ),
      );
    } on DioException catch (exception) {
      return Err(schoolFailureFrom(exception));
    } on FormatException {
      return const Err(SchoolUnexpectedFailure());
    }
  }
}
