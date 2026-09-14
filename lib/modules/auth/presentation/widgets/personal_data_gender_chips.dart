import 'package:flutter/material.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/ui/vanep_gender_chips.dart';
import '../../../../l10n/app_localizations.dart';
import '../formatters/profile_field_formatters.dart';

class PersonalDataGenderChips extends StatelessWidget {
  const PersonalDataGenderChips({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Gender? value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepGenderChips(
      value: value,
      onChanged: onChanged,
      labelOf: (gender) => profileGenderLabel(gender, l10n),
    );
  }
}
