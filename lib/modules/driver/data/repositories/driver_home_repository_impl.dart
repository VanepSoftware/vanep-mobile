import '../../domain/entities/driver_home_data.dart';
import '../../domain/repositories/driver_home_repository.dart';
import '../datasources/driver_home_remote_datasource.dart';

class DriverHomeRepositoryImpl implements DriverHomeRepository {
  const DriverHomeRepositoryImpl({required this.remote});

  final DriverHomeRemoteDataSource remote;

  @override
  Future<DriverHomeData> load() => remote.fetchHomeData();

  @override
  Future<void> startTrip(String tripId) => remote.startTrip(tripId);

  @override
  Future<void> confirmStop(StopConfirmation confirmation) =>
      remote.confirmStop(confirmation);
}
