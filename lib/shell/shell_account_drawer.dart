import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_vans_page.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/account_drawer.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:vanep_mobile/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/formatters/assistant_status_label.dart';
import 'package:vanep_mobile/modules/settings/presentation/pages/settings_page.dart';
import 'package:vanep_mobile/shell/shell_personal_data_slots.dart';

class ShellAccountDrawer extends StatelessWidget {
  const ShellAccountDrawer({
    required this.profile,
    this.openProfessionalData,
    super.key,
  });

  final UserProfile profile;
  final Future<void> Function(BuildContext context)? openProfessionalData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProfileSummaryCubit, ProfileSummaryState>(
      builder: (context, summaryState) {
        return AccountDrawer(
          profile: profile,
          photoUrl: summaryState.photoUrl,
          rating: summaryState.rating,
          city: summaryState.city,
          statusLabel: assistantStatusLabel(l10n, summaryState.assistantStatus),
          statusColor: assistantStatusColor(
            context.palette,
            summaryState.assistantStatus,
          ),
          isSummaryLoading: summaryState.status == ProfileSummaryStatus.loading,
          buildPersonalDataSlots: (context) =>
              buildShellPersonalDataSlots(context, profile),
          openSettings: openSettingsPage,
          openProfessionalData: openProfessionalData,
          openAssistantVans: (context) =>
              openAssistantVansPage(context, profile),
        );
      },
    );
  }
}

/// The account screen as a tab: same header and menu as [ShellAccountDrawer],
/// fed by the profile summary (GET /api/{clients,drivers,assistants}/me).
/// Pull down to reload it.
class ShellAccountProfileTab extends StatelessWidget {
  const ShellAccountProfileTab({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProfileSummaryCubit, ProfileSummaryState>(
      builder: (context, summaryState) {
        return RefreshIndicator(
          onRefresh: () =>
              refreshAccountWhenDrawerOpens(context, profile, isOpened: true),
          child: AccountProfileView(
            profile: profile,
            photoUrl: summaryState.photoUrl,
            rating: summaryState.rating,
            city: summaryState.city,
            statusLabel: assistantStatusLabel(
              l10n,
              summaryState.assistantStatus,
            ),
            statusColor: assistantStatusColor(
              context.palette,
              summaryState.assistantStatus,
            ),
            isSummaryLoading:
                summaryState.status == ProfileSummaryStatus.loading,
            buildPersonalDataSlots: (context) =>
                buildShellPersonalDataSlots(context, profile),
            openSettings: openSettingsPage,
            openAssistantVans: (context) =>
                openAssistantVansPage(context, profile),
          ),
        );
      },
    );
  }
}

Future<void> refreshAccountWhenDrawerOpens(
  BuildContext context,
  UserProfile profile, {
  required bool isOpened,
}) async {
  if (!isOpened) return;
  await Future.wait<void>([
    context.read<AuthCubit>().refreshSessionProfile(),
    context.read<ProfileSummaryCubit>().refresh(profile.type),
  ]);
}

/// "Minhas vans": accepting or declining an invite changes the linked vans and
/// the assistant status, so both are read again on the way back.
Future<void> openAssistantVansPage(
  BuildContext context,
  UserProfile profile,
) async {
  final vanSelector = context.read<AssistantVanSelectorCubit>();
  final summary = context.read<ProfileSummaryCubit>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => AssistantVansPage.withCubit()),
  );
  if (vanSelector.isClosed || summary.isClosed) return;
  await Future.wait<void>([
    vanSelector.loadVans(),
    summary.refresh(profile.type),
  ]);
}

Future<void> openNotifications(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<NotificationsCubit>(
        create: (_) => getIt<NotificationsCubit>()..load(),
        child: const NotificationsPage(),
      ),
    ),
  );
}
