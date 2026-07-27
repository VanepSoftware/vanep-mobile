import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../formatters/profile_field_formatters.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final empty = l10n.profileFieldEmpty;

    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: AppBar(
        backgroundColor: VanepColors.surface,
        foregroundColor: VanepColors.textPrimary,
        elevation: 0,
        title: Text(l10n.profilePersonalData, style: VanepTypography.cardTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PersonalDataField(
            label: l10n.profileFieldName,
            value: profileDisplayOrEmpty(profile.name, empty),
          ),
          const SizedBox(height: 12),
          PersonalDataField(
            label: l10n.profileFieldEmail,
            value: profileDisplayOrEmpty(profile.email, empty),
          ),
          const SizedBox(height: 12),
          PersonalDataField(
            label: l10n.profileFieldPhone,
            value: formatProfilePhone(profile.phone, empty),
          ),
          const SizedBox(height: 12),
          PersonalDataField(
            label: l10n.profileFieldDocument,
            value: formatProfileDocument(profile.document, empty),
          ),
          const SizedBox(height: 12),
          PersonalDataField(
            label: l10n.profileFieldBirthDate,
            value: formatProfileBirthDate(profile.birthDate, locale, empty),
          ),
          const SizedBox(height: 12),
          PersonalDataField(
            label: l10n.profileFieldGender,
            value: profileGenderLabel(profile.gender, l10n),
          ),
        ],
      ),
    );
  }
}

class PersonalDataField extends StatelessWidget {
  const PersonalDataField({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VanepColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: VanepTypography.cardSubtitle),
            const SizedBox(height: 4),
            Text(value, style: VanepTypography.cardTitle),
          ],
        ),
      ),
    );
  }
}
