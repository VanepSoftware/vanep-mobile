import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/ui/vanep_coming_soon_page.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/presentation/cubit/auth_cubit.dart';
import '../modules/auth/presentation/widgets/account_drawer.dart';
import '../modules/profile/presentation/cubit/profile_summary_cubit.dart';
import '../modules/profile/presentation/formatters/assistant_status_label.dart';

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
