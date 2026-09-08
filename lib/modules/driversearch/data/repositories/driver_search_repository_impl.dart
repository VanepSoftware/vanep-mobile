import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/driver_search_page.dart';
import '../../domain/failures/driver_search_failure.dart';
import '../../domain/repositories/driver_search_repository.dart';
import '../datasources/driver_search_remote_datasource.dart';

DriverSearchFailure driverSearchFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  return switch (status) {
    null => DriverSearchFailure.network,
    400 => DriverSearchFailure.placeNotResolved,
    429 => DriverSearchFailure.rateLimited,
    _ => DriverSearchFailure.unexpected,
  };
}

class DriverSearchRepositoryImpl implements DriverSearchRepository {
  const DriverSearchRepositoryImpl({required this.remote});

  final DriverSearchRemoteDataSource remote;

  @override
  Future<Result<DriverSearchFailure, DriverSearchPage>> searchByPlace(
    String placeId,
    String? sessionToken, {
    int page = 0,
  }) async {
    try {
      return Ok(await remote.searchByPlace(placeId, sessionToken, page: page));
    } on DioException catch (exception) {
      return Err(driverSearchFailureFrom(exception));
    }
  }
}
