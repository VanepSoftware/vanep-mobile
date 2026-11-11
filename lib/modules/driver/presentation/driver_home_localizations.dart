import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

extension DriverHomeMessageLocalization on DriverHomeMessage {
  String localize(AppLocalizations l10n) => switch (this) {
    DriverHomeMessage.unavailable => l10n.driverHomeUnavailable,
    DriverHomeMessage.refreshFailed => l10n.driverHomeRefreshFailed,
    DriverHomeMessage.stopChanged => l10n.driverHomeStopChanged,
    DriverHomeMessage.refreshAfterAction => l10n.driverHomeRefreshAfterAction,
    DriverHomeMessage.actionFailed => l10n.driverHomeActionFailed,
    DriverHomeMessage.approvalRequired => l10n.driverHomeApprovalRequired,
    DriverHomeMessage.noPendingRoute => l10n.driverHomeNoPendingRoute,
    DriverHomeMessage.subscription => l10n.driverHomeSubscription,
    DriverHomeMessage.documents => l10n.driverHomeDocuments,
    DriverHomeMessage.bothBlocked => l10n.driverHomeBothBlocked,
  };
}

String localizeDriverShift(AppLocalizations l10n, String shift) =>
    switch (shift) {
      'MORNING' => l10n.driverHomeMorning,
      'AFTERNOON' => l10n.driverHomeAfternoon,
      'NIGHT' => l10n.driverHomeNight,
      'FULLTIME' => l10n.driverHomeFulltime,
      _ => shift,
    };
