import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';

String vanFieldLabel(AppLocalizations l10n, VanField field) {
  return switch (field) {
    VanField.plate => l10n.driverVanFieldPlate,
    VanField.brand => l10n.driverVanFieldBrand,
    VanField.model => l10n.driverVanFieldModel,
    VanField.manufactureYear => l10n.driverVanFieldYear,
    VanField.color => l10n.driverVanFieldColor,
    VanField.capacity => l10n.driverVanFieldCapacity,
  };
}

String? vanFieldErrorLabel(
  AppLocalizations l10n,
  VanField field,
  VanFieldError? error,
) {
  return switch (error) {
    null => null,
    VanFieldError.required => l10n.driverVanFieldRequired,
    VanFieldError.invalid => switch (field) {
      VanField.plate => l10n.driverVanPlateInvalid,
      VanField.manufactureYear => l10n.driverVanYearInvalid,
      VanField.capacity => l10n.driverVanCapacityInvalid,
      VanField.brand ||
      VanField.model ||
      VanField.color => l10n.driverVanFieldRequired,
    },
  };
}

String driverVanFailureLabel(AppLocalizations l10n, DriverVanFailure failure) {
  return switch (failure) {
    DriverVanFailure.duplicatePlate => l10n.driverVanFailureDuplicatePlate,
    DriverVanFailure.invalidData => l10n.driverVanFailureInvalid,
    DriverVanFailure.network => l10n.driverVanFailureNetwork,
    DriverVanFailure.unexpected => l10n.driverVanFailureUnexpected,
  };
}

String vanPhotoSideLabel(AppLocalizations l10n, VanPhotoSide side) {
  return switch (side) {
    VanPhotoSide.front => l10n.driverVanPhotoFront,
    VanPhotoSide.side => l10n.driverVanPhotoSide,
  };
}

String vanPhotoUrlFor(DriverVan van, VanPhotoSide side) {
  return switch (side) {
        VanPhotoSide.front => van.photoFrontUrl,
        VanPhotoSide.side => van.photoSideUrl,
      } ??
      '';
}

String driverVanTitle(AppLocalizations l10n, DriverVan van) {
  return l10n.driverProfileVanTitle(
    van.model,
    van.manufactureYear.toString(),
    van.brand,
  );
}
