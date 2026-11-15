import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/datasources/van_central_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';

class VanCentralRepositoryImpl implements VanCentralRepository {
  const VanCentralRepositoryImpl({required this.remote});

  final VanCentralRemoteDataSource remote;

  @override
  Future<Result<VanCentralFailure, DriverOccupancy>> findOccupancy() =>
      guardVanCentralCall(remote.fetchOccupancy);

  @override
  Future<Result<VanCentralFailure, DriverAttendance>> findAttendance() =>
      guardVanCentralCall(remote.fetchAttendance);

  @override
  Future<Result<VanCentralFailure, DriverAttendance>> changeAcceptingStudents(
    bool acceptingStudents,
  ) => guardVanCentralCall(
    () => remote.updateAvailability(available: acceptingStudents),
  );

  @override
  Future<Result<VanCentralFailure, List<VanAssistant>>> listAssistants() =>
      guardVanCentralCall(remote.fetchAssistants);
}

Future<Result<VanCentralFailure, T>> guardVanCentralCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (error) {
    return Err(vanCentralFailureFrom(error));
  }
}

VanCentralFailure vanCentralFailureFrom(DioException error) {
  return error.response == null
      ? VanCentralFailure.network
      : VanCentralFailure.unexpected;
}
