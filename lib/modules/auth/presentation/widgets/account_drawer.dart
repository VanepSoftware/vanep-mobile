import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/builders/profile_menu_builder.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_menu_id.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_slots.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/profile_header.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/profile_menu_card.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class AccountDrawer extends StatelessWidget {
  const AccountDrawer({
    required this.profile,
    this.photoUrl,
    this.rating,
    this.city,
    this.statusLabel,
    this.statusColor,
    this.isSummaryLoading = false,
    this.buildPersonalDataSlots,
    this.openSettings,
    this.openProfessionalData,
    super.key,
  });

  final UserProfile profile;
  final String? photoUrl;
  final double? rating;
  final String? city;
  final String? statusLabel;
  final Color? statusColor;
  final bool isSummaryLoading;
  final PersonalDataSlotsBuilder? buildPersonalDataSlots;
  final Future<void> Function(BuildContext context)? openSettings;
  final Future<void> Function(BuildContext context)? openProfessionalData;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.palette.surface,
      child: SafeArea(
        child: AccountProfileView(
          profile: profile,
          photoUrl: photoUrl,
          rating: rating,
          city: city,
          statusLabel: statusLabel,
          statusColor: statusColor,
          isSummaryLoading: isSummaryLoading,
          buildPersonalDataSlots: buildPersonalDataSlots,
          openSettings: openSettings,
          openProfessionalData: openProfessionalData,
        ),
      ),
    );
  }
}

/// Profile header plus the account menu, shown inside [AccountDrawer] and as
/// the profile tab of shells that have one.
class AccountProfileView extends StatelessWidget {
  const AccountProfileView({
    required this.profile,
    this.photoUrl,
    this.rating,
    this.city,
    this.statusLabel,
    this.statusColor,
    this.isSummaryLoading = false,
    this.buildPersonalDataSlots,
    this.openSettings,
    this.openProfessionalData,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 24),
    super.key,
  });

  final UserProfile profile;
  final String? photoUrl;
  final double? rating;
  final String? city;
  final String? statusLabel;
  final Color? statusColor;
  final bool isSummaryLoading;
  final PersonalDataSlotsBuilder? buildPersonalDataSlots;
  final Future<void> Function(BuildContext context)? openSettings;
  final Future<void> Function(BuildContext context)? openProfessionalData;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final sections = buildProfileMenu(profile.type);
    final displayName = profile.name ?? profile.email ?? '';
    final hasPendingEmailConfirmation = profile.pendingEmail != null;

    return ListView(
      padding: padding,
      children: [
        ProfileHeader(
          name: displayName,
          email: profile.email,
          photoUrl: photoUrl,
          rating: rating,
          city: city,
          statusLabel: statusLabel,
          statusColor: statusColor,
          isSummaryLoading: isSummaryLoading,
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) const SizedBox(height: 16),
          ProfileMenuSectionView(
            section: sections[index],
            onItemSelected: (id) => handleProfileMenuSelection(
              context,
              profile,
              id,
              buildPersonalDataSlots: buildPersonalDataSlots,
              openSettings: openSettings,
              openProfessionalData: openProfessionalData,
            ),
            pendingEmailConfirmation: hasPendingEmailConfirmation,
          ),
        ],
      ],
    );
  }
}

Future<void> handleProfileMenuSelection(
  BuildContext context,
  UserProfile profile,
  ProfileMenuId id, {
  PersonalDataSlotsBuilder? buildPersonalDataSlots,
  Future<void> Function(BuildContext context)? openSettings,
  Future<void> Function(BuildContext context)? openProfessionalData,
}) async {
  switch (id) {
    case ProfileMenuId.personalData:
      final syncProfile = context.read<AuthCubit>().syncProfile;
      final slots =
          buildPersonalDataSlots?.call(context) ?? const PersonalDataSlots();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<PersonalDataCubit>(param1: syncProfile)..load(),
            child: PersonalDataPage(slots: slots),
          ),
        ),
      );
    case ProfileMenuId.settings:
      await openSettings?.call(context);
    case ProfileMenuId.signOut:
      await confirmAndSignOut(context);
    case ProfileMenuId.professionalData:
      await openProfessionalData?.call(context);
    case ProfileMenuId.paymentMethods:
    case ProfileMenuId.assistantInvite:
    case ProfileMenuId.privacySecurity:
      break;
  }
}

Future<void> confirmAndSignOut(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.profileSignOutTitle,
    message: l10n.profileSignOutMessage,
    confirmLabel: l10n.signOutButton,
    cancelLabel: l10n.profileSignOutCancel,
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return;
  await context.read<AuthCubit>().signOut();
}
