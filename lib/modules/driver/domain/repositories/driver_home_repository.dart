import '../entities/driver_home_data.dart';

abstract interface class DriverHomeRepository {
  Future<DriverHomeData> load();
  // Implementações devem validar RN-02/bloqueios no servidor e usar idempotência.
  Future<void> startTrip(String tripId);
  Future<void> confirmStop(StopConfirmation confirmation);
}
