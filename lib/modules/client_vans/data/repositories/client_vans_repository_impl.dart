import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/domain/repositories/client_vans_repository.dart';

class ClientVansRepositoryImpl implements ClientVansRepository {
  const ClientVansRepositoryImpl({
    required this.dataSource,
    this.fallbackDataSource,
  });

  final ClientVansDataSource dataSource;
  final ClientVansDataSource? fallbackDataSource;

  @override
  Future<Result<ClientVansFailure, List<ClientVan>>> findMyVans() async {
    try {
      final vans = await dataSource.fetchMyVans();
      if (vans.isEmpty && fallbackDataSource != null) {
        final fallbackVans = await fallbackDataSource!.fetchMyVans();
        if (fallbackVans.isNotEmpty) {
          return Ok(fallbackVans);
        }
      }
      return Ok(vans);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return const Err(ClientVansFailure.unauthenticated);
      }
      if (fallbackDataSource != null) {
        try {
          final fallbackVans = await fallbackDataSource!.fetchMyVans();
          return Ok(fallbackVans);
        } catch (_) {}
      }
      return const Err(ClientVansFailure.network);
    } catch (_) {
      if (fallbackDataSource != null) {
        try {
          final fallbackVans = await fallbackDataSource!.fetchMyVans();
          return Ok(fallbackVans);
        } catch (_) {}
      }
      return const Err(ClientVansFailure.unexpected);
    }
  }
}
