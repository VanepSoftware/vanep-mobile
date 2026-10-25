import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_greeting_header.dart';
import 'package:vanep_mobile/core/ui/vanep_home_top_bar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/client_home_skeleton.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/first_access_extras.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_shortcuts_grid.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/needs_you_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/today_section_view.dart';

class ClientHomeTab extends StatelessWidget {
  const ClientHomeTab({
    required this.displayName,
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    required this.onFindVanTapped,
    required this.onAddAddressTapped,
    required this.onAddDependentTapped,
    super.key,
  });

  final String displayName;
  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;
  final VoidCallback onFindVanTapped;
  final VoidCallback onAddAddressTapped;
  final VoidCallback onAddDependentTapped;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientHomeCubit>();

    return SafeArea(
      bottom: false,
      child: BlocBuilder<ClientHomeCubit, ClientHomeState>(
        builder: (context, state) {
          final home = state.home;
          return RefreshIndicator(
            onRefresh: cubit.loadHome,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                VanepHomeTopBar(
                  onMenuTapped: onMenuTapped,
                  onNotificationsTapped: onNotificationsTapped,
                ),
                const SizedBox(height: 8),
                ClientHomeGreeting(displayName: displayName, home: home),
                const SizedBox(height: 20),
                if (home != null)
                  ClientHomeBlocks(
                    home: home,
                    onFindVanTapped: onFindVanTapped,
                    onAddAddressTapped: onAddAddressTapped,
                    onAddDependentTapped: onAddDependentTapped,
                  )
                else if (state.hasLoadFailed)
                  VanepErrorView(
                    message: AppLocalizations.of(context)!.clientHomeLoadError,
                    retryLabel: AppLocalizations.of(context)!.clientHomeRetry,
                    onRetry: cubit.loadHome,
                  )
                else
                  const ClientHomeSkeleton(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ClientHomeGreeting extends StatelessWidget {
  const ClientHomeGreeting({
    required this.displayName,
    required this.home,
    super.key,
  });

  final String displayName;
  final ClientHome? home;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = this.home;
    if (home == null) return VanepGreetingHeader(displayName: displayName);

    return VanepGreetingHeader(
      displayName: displayName,
      title: formatHeadline(l10n, home.headline, firstNameOf(displayName)),
      subtitle: home.today is FirstStepsSection
          ? l10n.clientHomeFirstAccessSubtitle
          : formatDateLine(l10n, home.date),
    );
  }
}

class ClientHomeBlocks extends StatelessWidget {
  const ClientHomeBlocks({
    required this.home,
    required this.onFindVanTapped,
    required this.onAddAddressTapped,
    required this.onAddDependentTapped,
    super.key,
  });

  final ClientHome home;
  final VoidCallback onFindVanTapped;
  final VoidCallback onAddAddressTapped;
  final VoidCallback onAddDependentTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TodaySectionView(
          section: home.today,
          now: home.date,
          onFindVanTapped: onFindVanTapped,
          onAddAddressTapped: onAddAddressTapped,
          onAddDependentTapped: onAddDependentTapped,
        ),
        if (!home.needsYou.isEmpty) ...[
          const SizedBox(height: homeBlockSpacing),
          NeedsYouSection(summary: home.needsYou, now: home.date),
        ],
        const SizedBox(height: homeBlockSpacing),
        HomeSectionHeader(title: l10n.clientHomeShortcutsTitle),
        HomeShortcutsGrid(
          enabledShortcuts: home.enabledShortcuts,
          onShortcutTapped: (shortcut) =>
              openUnavailableFeature(context, formatShortcut(l10n, shortcut)),
        ),
        if (home.today is FirstStepsSection) ...[
          const SizedBox(height: homeBlockSpacing),
          HomeSectionHeader(title: l10n.clientHomeHowItWorksTitle),
          const HowVanepWorksCard(),
        ],
      ],
    );
  }
}
