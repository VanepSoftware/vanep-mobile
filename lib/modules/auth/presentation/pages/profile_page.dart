import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/ui/vanep_confirm_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/builders/profile_menu_builder.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/value_objects/profile_menu_id.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/personal_data_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_card.dart';
import 'personal_data_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.profile,
    this.photoUrl,
    this.rating,
    this.city,
    this.statusLabel,
    this.statusColor,
    this.onRefresh,
    super.key,
  });

  final UserProfile profile;
  final String? photoUrl;
  final double? rating;
  final String? city;
  final String? statusLabel;
  final Color? statusColor;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = buildProfileMenu(profile.type);
    final displayName = profile.name ?? profile.email ?? '';
    final hasPendingEmailConfirmation = profile.pendingEmail != null;
    final refresh = onRefresh;
    final listView = ListView(
      physics: refresh == null
          ? null
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 124),
      children: [
        Text(l10n.navProfile, style: VanepTypography.pageTitle),
        const SizedBox(height: 20),
        ProfileHeader(
          name: displayName,
          email: profile.email,
          photoUrl: photoUrl,
          rating: rating,
          city: city,
          statusLabel: statusLabel,
          statusColor: statusColor,
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
    );

    return SafeArea(
      bottom: false,
      child: refresh == null
          ? listView
          : RefreshIndicator(
              onRefresh: refresh,
              backgroundColor: VanepColors.card,
              color: VanepColors.brand,
              child: listView,
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
    case ProfileMenuId.addresses:
    case ProfileMenuId.paymentMethods:
    case ProfileMenuId.dependents:
    case ProfileMenuId.vans:
    case ProfileMenuId.contracts:
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
