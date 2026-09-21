import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/ui/vanep_confirm_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/builders/profile_menu_builder.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/value_objects/profile_menu_id.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/personal_data_cubit.dart';
import '../pages/personal_data_page.dart';
import 'profile_header.dart';
import 'profile_menu_card.dart';

class AccountDrawer extends StatelessWidget {
  const AccountDrawer({
    required this.profile,
    this.photoUrl,
    this.rating,
    this.city,
    this.statusLabel,
    this.statusColor,
    this.isSummaryLoading = false,
    super.key,
  });

  final UserProfile profile;
  final String? photoUrl;
  final double? rating;
  final String? city;
  final String? statusLabel;
  final Color? statusColor;
  final bool isSummaryLoading;

  @override
  Widget build(BuildContext context) {
    final sections = buildProfileMenu(profile.type);
    final displayName = profile.name ?? profile.email ?? '';
    final hasPendingEmailConfirmation = profile.pendingEmail != null;

    return Drawer(
      backgroundColor: VanepColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
                onItemSelected: (id) =>
                    handleProfileMenuSelection(context, profile, id),
                pendingEmailConfirmation: hasPendingEmailConfirmation,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> handleProfileMenuSelection(
  BuildContext context,
  UserProfile profile,
  ProfileMenuId id,
) async {
  switch (id) {
    case ProfileMenuId.personalData:
      final syncProfile = context.read<AuthCubit>().syncProfile;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<PersonalDataCubit>(param1: syncProfile)..load(),
            child: const PersonalDataPage(),
          ),
        ),
      );
    case ProfileMenuId.signOut:
      await confirmAndSignOut(context);
    case ProfileMenuId.paymentMethods:
    case ProfileMenuId.professionalData:
    case ProfileMenuId.assistantInvite:
    case ProfileMenuId.settings:
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
