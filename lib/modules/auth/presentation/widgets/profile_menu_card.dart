import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_menu_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/builders/profile_menu_builder.dart';
import '../../domain/value_objects/profile_menu_id.dart';

class ProfileMenuSectionView extends StatelessWidget {
  const ProfileMenuSectionView({
    required this.section,
    required this.onItemSelected,
    this.pendingEmailConfirmation = false,
    super.key,
  });

  final ProfileMenuSection section;
  final ValueChanged<ProfileMenuId> onItemSelected;
  final bool pendingEmailConfirmation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = section.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              profileSectionTitleLabel(title, l10n),
              style: VanepTypography.sectionTitle.copyWith(
                color: VanepColors.textPrimary,
              ),
            ),
          ),
        ],
        ProfileMenuCard(
          section: section,
          onItemSelected: onItemSelected,
          pendingEmailConfirmation: pendingEmailConfirmation,
        ),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    required this.section,
    required this.onItemSelected,
    this.pendingEmailConfirmation = false,
    super.key,
  });

  final ProfileMenuSection section;
  final ValueChanged<ProfileMenuId> onItemSelected;
  final bool pendingEmailConfirmation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepMenuCard(
      items: [
        for (final entry in section.entries)
          VanepMenuItem(
            label: profileMenuLabel(entry.id, l10n),
            icon: profileMenuIcon(entry.id),
            enabled: entry.enabled,
            isDestructive: entry.id == ProfileMenuId.signOut,
            warningSubtitle:
                pendingEmailConfirmation &&
                    entry.id == ProfileMenuId.personalData
                ? l10n.profilePendingEmailMenuSubtitle
                : null,
            onTap: () => onItemSelected(entry.id),
          ),
      ],
    );
  }
}

String profileMenuLabel(ProfileMenuId id, AppLocalizations l10n) {
  return switch (id) {
    ProfileMenuId.personalData => l10n.profilePersonalData,
    ProfileMenuId.addresses => l10n.profileAddresses,
    ProfileMenuId.paymentMethods => l10n.profilePaymentMethods,
    ProfileMenuId.professionalData => l10n.profileProfessionalData,
    ProfileMenuId.assistantInvite => l10n.profileAssistantInvite,
    ProfileMenuId.settings => l10n.profileSettings,
    ProfileMenuId.privacySecurity => l10n.profilePrivacySecurity,
    ProfileMenuId.signOut => l10n.signOutButton,
  };
}

IconData profileMenuIcon(ProfileMenuId id) {
  return switch (id) {
    ProfileMenuId.personalData => Icons.person_outline,
    ProfileMenuId.addresses => Icons.location_on_outlined,
    ProfileMenuId.paymentMethods => Icons.credit_card_outlined,
    ProfileMenuId.professionalData => Icons.work_outline,
    ProfileMenuId.assistantInvite => Icons.mail_outline,
    ProfileMenuId.settings => Icons.settings_outlined,
    ProfileMenuId.privacySecurity => Icons.shield_outlined,
    ProfileMenuId.signOut => Icons.logout,
  };
}

String profileSectionTitleLabel(
  ProfileMenuSectionTitle title,
  AppLocalizations l10n,
) {
  return switch (title) {
    ProfileMenuSectionTitle.account => l10n.profileSectionAccount,
    ProfileMenuSectionTitle.services => l10n.profileSectionServices,
    ProfileMenuSectionTitle.preferences => l10n.profileSectionPreferences,
  };
}
