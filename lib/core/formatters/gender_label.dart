import '../../l10n/app_localizations.dart';
import '../domain/gender.dart';

String genderLabel(Gender? gender, AppLocalizations l10n) {
  return switch (gender) {
    Gender.male => l10n.profileGenderMale,
    Gender.female => l10n.profileGenderFemale,
    Gender.other => l10n.profileGenderOther,
    null => l10n.profileGenderUnspecified,
  };
}
