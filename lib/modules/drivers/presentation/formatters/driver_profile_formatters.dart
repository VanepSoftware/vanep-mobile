import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/failures/driver_failure.dart';

String formatVanTitle(AppLocalizations l10n, DriverProfileVehicle vehicle) {
  return l10n.driverProfileVanTitle(
    vehicle.model,
    vehicle.manufactureYear.toString(),
    vehicle.brand,
  );
}

String formatVanDetails(AppLocalizations l10n, DriverProfileVehicle vehicle) {
  return '${l10n.driverProfileVanCapacity(vehicle.capacity)} · ${vehicle.color}';
}

String formatServiceAreaList(List<String> serviceAreas) {
  return serviceAreas.where((area) => area.trim().isNotEmpty).join(', ');
}

String driverProfileFailureLabel(AppLocalizations l10n, DriverFailure failure) {
  return switch (failure) {
    NotFoundDriverFailure() => l10n.driverProfileNotFound,
    NetworkDriverFailure() ||
    UnexpectedDriverFailure() => l10n.driverProfileLoadError,
  };
}
