import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/formatters/gender_label.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepGenderSelect extends StatelessWidget {
  const VanepGenderSelect({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final Gender? value;
  final ValueChanged<Gender?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final choices = <Gender?>[...Gender.values, null];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepFieldLabel(label: label),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: vanepInputDecoration(context).copyWith(
            enabled: enabled,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
          child: Theme(
            data: Theme.of(context)
                .copyWith(disabledColor: context.palette.textMuted),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Gender?>(
                value: value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: context.palette.card,
                icon: Icon(
                  Icons.expand_more,
                  color: enabled
                      ? context.palette.textSecondary
                      : context.palette.textMuted,
                ),
                style: context.typography.fieldValue,
                items: [
                  for (final choice in choices)
                    DropdownMenuItem<Gender?>(
                      value: choice,
                      child: Text(genderLabel(choice, l10n)),
                    ),
                ],
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
