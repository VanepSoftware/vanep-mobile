import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/account_drawer.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/formatters/assistant_status_label.dart';
import 'package:vanep_mobile/shell/shell_personal_data_slots.dart';

class ShellAccountDrawer extends StatelessWidget {
  const ShellAccountDrawer({required this.profile, super.key});

  final UserProfile profile;

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
          statusColor: assistantStatusColor(summaryState.assistantStatus),
          isSummaryLoading: summaryState.status == ProfileSummaryStatus.loading,
          buildPersonalDataSlots: (context) =>
              buildShellPersonalDataSlots(context, profile),
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

Future<void> openNotifications(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return openComingSoonPage(
    context,
    title: l10n.navNotifications,
    message: l10n.comingSoon,
  );
}
