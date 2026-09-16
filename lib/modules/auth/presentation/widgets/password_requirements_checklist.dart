import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/password_policy.dart';

class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({
    required this.password,
    required this.highlightUnmet,
    super.key,
  });

  final String password;
  final bool highlightUnmet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final requirement in PasswordRequirement.values)
          PasswordRequirementRow(
            label: passwordRequirementLabel(l10n, requirement),
            met: requirement.isMetBy(password),
            highlightUnmet: highlightUnmet,
          ),
      ],
    );
  }
}

String passwordRequirementLabel(
  AppLocalizations l10n,
  PasswordRequirement requirement,
) {
  return switch (requirement) {
    PasswordRequirement.minLength => l10n.passwordRequirementMinLength(
      PasswordPolicy.minLength,
    ),
    PasswordRequirement.uppercaseLetter => l10n.passwordRequirementUppercase,
    PasswordRequirement.specialCharacter => l10n.passwordRequirementSpecial,
  };
}

class PasswordRequirementRow extends StatelessWidget {
  const PasswordRequirementRow({
    required this.label,
    required this.met,
    required this.highlightUnmet,
    super.key,
  });

  final String label;
  final bool met;
  final bool highlightUnmet;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? VanepColors.success
        : highlightUnmet
        ? VanepColors.danger
        : VanepColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: VanepTypography.cardSubtitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
