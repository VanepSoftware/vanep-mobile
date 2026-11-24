import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/domain/repositories/client_vans_repository.dart';

class ClientVansRepositoryImpl implements ClientVansRepository {
  const ClientVansRepositoryImpl({required this.dataSource});

  final ClientVansDataSource dataSource;

  @override
  Future<Result<ClientVansFailure, List<ClientVan>>> findMyVans() async {
    try {
      final vans = await dataSource.fetchMyVans();
      return Ok(vans);
    } on DioException catch (e) {
      final problem = ApiProblem.fromDioException(e);
      if (problem.matchesAnyCode(const [
            ApiErrorCodes.authUnauthenticated,
            ApiErrorCodes.authForbidden,
          ]) ||
          problem.status == 401 ||
          problem.status == 403) {
        return const Err(ClientVansFailure.unauthenticated);
      }
      return const Err(ClientVansFailure.network);
    } catch (_) {
      return const Err(ClientVansFailure.unexpected);
    }
  }
}
