import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/builders/profile_menu_builder.dart';
import '../../domain/value_objects/profile_menu_id.dart';

class ProfileMenuSectionView extends StatelessWidget {
  const ProfileMenuSectionView({
    required this.section,
    required this.onItemSelected,
    super.key,
  });

  final ProfileMenuSection section;
  final ValueChanged<ProfileMenuId> onItemSelected;

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
        ProfileMenuCard(section: section, onItemSelected: onItemSelected),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    required this.section,
    required this.onItemSelected,
    super.key,
  });

  final ProfileMenuSection section;
  final ValueChanged<ProfileMenuId> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: VanepColors.card,
      elevation: 1,
      shadowColor: VanepColors.textPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (var index = 0; index < section.entries.length; index++) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: VanepColors.divider,
              ),
            ProfileMenuTile(
              entry: section.entries[index],
              label: profileMenuLabel(section.entries[index].id, l10n),
              icon: profileMenuIcon(section.entries[index].id),
              onTap: section.entries[index].enabled
                  ? () => onItemSelected(section.entries[index].id)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    required this.entry,
    required this.label,
    required this.icon,
    this.onTap,
    super.key,
  });

  final ProfileMenuEntry entry;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = entry.enabled;
    final isSignOut = entry.id == ProfileMenuId.signOut;
    final foreground = !enabled
        ? VanepColors.textMuted
        : isSignOut
        ? VanepColors.danger
        : VanepColors.textPrimary;
    final iconColor = !enabled
        ? VanepColors.textMuted
        : isSignOut
        ? VanepColors.danger
        : VanepColors.textSecondary;
    final iconBackground = isSignOut && enabled
        ? VanepColors.danger.withValues(alpha: 0.10)
        : VanepColors.searchField;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: VanepTypography.cardTitle.copyWith(color: foreground),
                ),
              ),
              if (!isSignOut)
                Icon(
                  Icons.chevron_right,
                  color: enabled ? VanepColors.textMuted : VanepColors.divider,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String profileMenuLabel(ProfileMenuId id, AppLocalizations l10n) {
  return switch (id) {
    ProfileMenuId.personalData => l10n.profilePersonalData,
    ProfileMenuId.addresses => l10n.profileAddresses,
    ProfileMenuId.paymentMethods => l10n.profilePaymentMethods,
    ProfileMenuId.dependents => l10n.profileDependents,
    ProfileMenuId.vans => l10n.profileVans,
    ProfileMenuId.contracts => l10n.profileContracts,
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
    ProfileMenuId.dependents => Icons.family_restroom_outlined,
    ProfileMenuId.vans => Icons.airport_shuttle_outlined,
    ProfileMenuId.contracts => Icons.description_outlined,
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
