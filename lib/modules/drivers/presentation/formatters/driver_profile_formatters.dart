import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';

class DriverVehiclePhotoEntry {
  const DriverVehiclePhotoEntry({
    required this.url,
    required this.vanTitle,
    required this.slotLabel,
  });

  final String url;
  final String vanTitle;
  final String slotLabel;
}

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

String formatVanModelYear(
  AppLocalizations l10n,
  DriverProfileVehicle vehicle,
) {
  return l10n.driverProfileVanModelYear(vehicle.model, vehicle.manufactureYear);
}

String formatVanPublicSubtitle(
  AppLocalizations l10n,
  DriverProfileVehicle vehicle,
) {
  final parts = <String>[
    vehicle.color,
    l10n.driverProfileVanCapacity(vehicle.capacity),
    if (vehicle.hasAssistant) l10n.driverProfileVanWithAssistant,
  ];
  return parts.where((part) => part.trim().isNotEmpty).join(' · ');
}

String formatServiceAreaList(List<String> serviceAreas) {
  return serviceAreas
      .map((area) => area.trim())
      .where((area) => area.isNotEmpty)
      .join(', ');
}

String formatDriverRating(AppLocalizations l10n, double rating) {
  return NumberFormat('0.0', l10n.localeName).format(rating);
}

String driverProfileFailureLabel(
  AppLocalizations l10n,
  DriverFailure failure,
) {
  return switch (failure) {
    NotFoundDriverFailure() => l10n.driverProfileNotFound,
    NetworkDriverFailure() ||
    UnexpectedDriverFailure() => l10n.driverProfileLoadError,
  };
}

String? driverProfileCoverPhotoUrl(DriverProfile profile) {
  for (final vehicle in profile.vehicles) {
    final front = vehicle.photoFrontUrl;
    if (front != null && front.isNotEmpty) return front;
    final side = vehicle.photoSideUrl;
    if (side != null && side.isNotEmpty) return side;
  }
  return null;
}

List<DriverVehiclePhotoEntry> collectDriverVehiclePhotos(
  AppLocalizations l10n,
  DriverProfile profile,
) {
  final photos = <DriverVehiclePhotoEntry>[];
  for (final vehicle in profile.vehicles) {
    final title = formatVanModelYear(l10n, vehicle);
    final front = vehicle.photoFrontUrl;
    if (front != null && front.isNotEmpty) {
      photos.add(
        DriverVehiclePhotoEntry(
          url: front,
          vanTitle: title,
          slotLabel: l10n.driverVanPhotoFront,
        ),
      );
    }
    final side = vehicle.photoSideUrl;
    if (side != null && side.isNotEmpty) {
      photos.add(
        DriverVehiclePhotoEntry(
          url: side,
          vanTitle: title,
          slotLabel: l10n.driverVanPhotoSide,
        ),
      );
    }
  }
  return photos;
}
