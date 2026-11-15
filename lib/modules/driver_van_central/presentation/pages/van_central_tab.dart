import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/widgets/van_central_menus.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/widgets/van_register_prompt.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/widgets/van_selector.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/widgets/van_summary_card.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanCentralTab extends StatelessWidget {
  const VanCentralTab({
    required this.onRegisterVan,
    required this.onOpenVanDetails,
    required this.onOpenServiceAreas,
    required this.onOpenComingSoon,
    super.key,
  });

  final Future<void> Function() onRegisterVan;
  final Future<void> Function() onOpenVanDetails;
  final Future<void> Function() onOpenServiceAreas;
  final Future<void> Function(String title) onOpenComingSoon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanCentralCubit>();

    Future<void> openThenRefresh(Future<void> Function() open) async {
      await open();
      await cubit.refresh();
    }

    final actions = VanCentralActions(
      onRegisterVan: () => openThenRefresh(onRegisterVan),
      onOpenVanDetails: () => openThenRefresh(onOpenVanDetails),
      onOpenServiceAreas: () => openThenRefresh(onOpenServiceAreas),
      onOpenComingSoon: onOpenComingSoon,
      onAcceptingStudentsChanged: cubit.setAcceptingStudents,
    );

    return BlocConsumer<VanCentralCubit, VanCentralState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (context, state) {
        VanepFeedback.showError(context, l10n.vanCentralAttendanceError);
        cubit.clearNotice();
      },
      builder: (context, state) {
        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: context.palette.action,
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                VanCentralHeader(
                  showAddVan: state.hasVans,
                  onAddVan: actions.onRegisterVan,
                ),
                const SizedBox(height: 18),
                VanCentralBody(state: state, actions: actions),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VanCentralHeader extends StatelessWidget {
  const VanCentralHeader({
    required this.showAddVan,
    required this.onAddVan,
    super.key,
  });

  final bool showAddVan;
  final VoidCallback onAddVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Text(l10n.navVans, style: context.typography.pageTitle),
        ),
        if (showAddVan)
          IconButton.outlined(
            tooltip: l10n.vanCentralAddVan,
            onPressed: onAddVan,
            style: IconButton.styleFrom(
              backgroundColor: context.palette.card,
              side: BorderSide(color: context.palette.inputBorder),
            ),
            icon: Icon(Icons.add, color: context.palette.textPrimary),
          ),
      ],
    );
  }
}

class VanCentralBody extends StatelessWidget {
  const VanCentralBody({required this.state, required this.actions, super.key});

  final VanCentralState state;
  final VanCentralActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedVan = state.selectedVan;

    return switch (state.status) {
      VanCentralStatus.loading => Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(color: context.palette.action),
        ),
      ),
      VanCentralStatus.loadFailed => VanepErrorView(
        message: l10n.vanCentralLoadError,
        retryLabel: l10n.driversRetryButton,
        onRetry: context.read<VanCentralCubit>().load,
      ),
      VanCentralStatus.loaded when selectedVan == null => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.vanCentralNoVanSubtitle, style: context.typography.body),
          const SizedBox(height: 22),
          VanRegisterPrompt(onRegisterVan: actions.onRegisterVan),
          const SizedBox(height: 22),
          VanCentralLockedMenus(state: state, actions: actions),
        ],
      ),
      VanCentralStatus.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.vans.length > 1) ...[
            VanSelector(
              vans: state.vans,
              selectedVanToken: selectedVan!.token,
              onSelected: context.read<VanCentralCubit>().selectVan,
            ),
            const SizedBox(height: 18),
          ],
          VanSummaryCard(
            van: selectedVan!,
            occupancy: state.selectedVanOccupancy,
            occupancyUnavailableMessage: state.vans.length > 1
                ? l10n.vanCentralOccupancyPerVanUnavailable
                : null,
            withAssistant: state.hasWorkingAssistant,
          ),
          const SizedBox(height: 18),
          VanCentralMenus(state: state, actions: actions),
        ],
      ),
    };
  }
}
