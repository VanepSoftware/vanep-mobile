import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/gender.dart';
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final gender in Gender.values)
          GenderChip(
            label: profileGenderLabel(gender, l10n),
            selected: value == gender,
            onTap: () => onChanged(gender),
          ),
      ],
    );
  }
}

class GenderChip extends StatelessWidget {
  const GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VanepColors.brand : VanepColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: VanepTypography.cardSubtitle.copyWith(
              color: selected
                  ? VanepColors.backgroundDeep
                  : VanepColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
