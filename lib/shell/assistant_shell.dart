import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/core/ui/vanep_home_top_bar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_van_selector_sheet.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/shell/assistant_bottom_nav.dart';
import 'package:vanep_mobile/shell/shell_account_drawer.dart';

class AssistantShell extends StatefulWidget {
  const AssistantShell({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  @override
  State<AssistantShell> createState() => AssistantShellState();
}

class AssistantShellState extends State<AssistantShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VanepColors.surface,
      drawer: ShellAccountDrawer(profile: widget.profile),
      onDrawerChanged: (isOpened) => refreshAccountWhenDrawerOpens(
        context,
        widget.profile,
        isOpened: isOpened,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  VanepHomeTopBar(
                    onMenuTapped: () => scaffoldKey.currentState?.openDrawer(),
                    onNotificationsTapped: () => openNotifications(context),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AssistantVanSelectorCubit, AssistantVanSelectorState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const VanepCard(
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: VanepColors.action,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (state.vans.isEmpty) {
                        return VanepCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: VanepColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.assistantNoVansLinked,
                                  style: VanepTypography.cardSubtitle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.hasActiveVan) {
                        final van = state.selectedVan!;
                        final vanTitle = van.model.isNotEmpty
                            ? '${van.model} • ${van.plate}'
                            : van.plate;
                        final shiftLabel = assistantShiftLabel(l10n, van.shift);
                        final subtitle = shiftLabel.isNotEmpty
                            ? '${l10n.assistantActiveVan} • $shiftLabel'
                            : l10n.assistantActiveVan;

                        return VanepCard(
                          onTap: state.hasMultipleVans
                              ? () => showAssistantVanSelectorSheet(
                                    context,
                                    vans: state.vans,
                                    selectedVan: state.selectedVan,
                                    onSelectVan: (selected) => context
                                        .read<AssistantVanSelectorCubit>()
                                        .selectVan(selected),
                                  )
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: VanepColors.actionSurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.airport_shuttle_rounded,
                                  color: VanepColors.action,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      vanTitle,
                                      style: VanepTypography.cardTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: VanepTypography.cardSubtitle,
                                    ),
                                  ],
                                ),
                              ),
                              if (state.hasMultipleVans)
                                TextButton(
                                  onPressed: () => showAssistantVanSelectorSheet(
                                    context,
                                    vans: state.vans,
                                    selectedVan: state.selectedVan,
                                    onSelectVan: (selected) => context
                                        .read<AssistantVanSelectorCubit>()
                                        .selectVan(selected),
                                  ),
                                  child: Text(
                                    l10n.assistantSwitchVan,
                                    style: VanepTypography.linkAction,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  VanepComingSoon(
                    title: l10n.navTodayRoute,
                    message: l10n.comingSoon,
                  ),
                  VanepComingSoon(
                    title: l10n.navStudents,
                    message: l10n.comingSoon,
                  ),
                  VanepComingSoon(
                    title: l10n.navAssistantProfile,
                    message: l10n.comingSoon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AssistantBottomNav(
        currentIndex: selectedIndex,
        onDestinationSelected: selectShellTab,
      ),
    );
  }

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
  }
}
