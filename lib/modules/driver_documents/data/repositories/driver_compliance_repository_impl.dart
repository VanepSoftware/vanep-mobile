import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/driver_compliance_dto.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/driver_compliance_repository.dart';

class DriverComplianceRepositoryImpl implements DriverComplianceRepository {
  const DriverComplianceRepositoryImpl(this.remote);

  final DriverDocumentsRemoteDataSource remote;

  @override
  Future<Result<ComplianceFailure, DriverCompliance>> loadMine() async {
    try {
      return Ok(DriverComplianceDto.fromJson(await remote.fetchCompliance()));
    } on DioException catch (error) {
      return Err(
        error.response == null
            ? ComplianceFailure.network
            : ComplianceFailure.unexpected,
      );
    } on FormatException {
      return const Err(ComplianceFailure.unexpected);
    }
  }
}
