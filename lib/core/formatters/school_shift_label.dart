import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

String formatShift(AppLocalizations l10n, SchoolShift shift) {
  return switch (shift) {
    SchoolShift.morning => l10n.clientHomeShiftMorning,
    SchoolShift.afternoon => l10n.clientHomeShiftAfternoon,
  };
}
