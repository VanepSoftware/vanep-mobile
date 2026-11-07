import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_negotiation_actions.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_request_sections.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';

class DriverServiceRequestPage extends StatelessWidget {
  const DriverServiceRequestPage({
    required this.actions,
    this.clock = DateTime.now,
    super.key,
  });

  final DriverNegotiationActions actions;
  final DateTime Function() clock;

  void onStateChanged(BuildContext context, DriverServiceRequestState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.status == DriverServiceRequestStatus.notFound) {
      VanepFeedback.showError(context, l10n.negotiationFailureNotFound);
      Navigator.of(context).pop(true);
    } else if (state.actionFailure case final failure?) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverServiceRequestCubit>();

    return BlocConsumer<DriverServiceRequestCubit, DriverServiceRequestState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.actionFailure != previous.actionFailure,
      listener: onStateChanged,
      builder: (context, state) {
        final request = state.request;
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(
            title: l10n.negotiationHistoryRequestSent,
            caption: request == null
                ? null
                : formatClientAndChildren(l10n, request),
          ),
          body: switch (state.status) {
            DriverServiceRequestStatus.ready when request != null =>
              RefreshIndicator(
                onRefresh: cubit.load,
                child: DriverServiceRequestBody(
                  request: request,
                  actions: actions,
                  now: clock(),
                ),
              ),
            DriverServiceRequestStatus.loadFailed => VanepErrorView(
              message: l10n.proposalDetailLoadError,
              retryLabel: l10n.clientProposalsRetry,
              onRetry: cubit.load,
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: VanepColors.action),
            ),
          },
          bottomNavigationBar: request != null && state.canAnswer
              ? DriverAnswerFooter(
                  onDecline: () => declineAndLeave(
                    context,
                    actions: actions,
                    request: request,
                    reload: cubit.load,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class DriverServiceRequestBody extends StatelessWidget {
  const DriverServiceRequestBody({
    required this.request,
    required this.actions,
    required this.now,
    super.key,
  });

  final DriverServiceRequest request;
  final DriverNegotiationActions actions;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = request.notes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        DriverClientCard(
          request: request,
          subtitle: formatRequestReceived(l10n, request, now),
          onChat: actions.chatWith(request),
        ),
        const SizedBox(height: detailSectionSpacing),
        DriverStudentsSection(request: request),
        const SizedBox(height: detailSectionSpacing),
        DriverRouteSection(request: request),
        const SizedBox(height: detailSectionSpacing),
        DriverRequestedDaysSection(request: request),
        const SizedBox(height: detailSectionSpacing),
        DriverRequestTermsCard(request: request),
        if (notes != null && notes.trim().isNotEmpty) ...[
          const SizedBox(height: detailSectionSpacing),
          DetailTextSection(
            title: l10n.driverRequestFamilyMessage,
            text: notes,
          ),
        ],
      ],
    );
  }
}

class DriverAnswerFooter extends StatelessWidget {
  const DriverAnswerFooter({required this.onDecline, super.key});

  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: VanepColors.card,
          border: Border(top: BorderSide(color: VanepColors.divider)),
        ),
        child: VanepSecondaryButton(
          label: l10n.proposalDetailDecline,
          isDestructive: true,
          onPressed: onDecline,
        ),
      ),
    );
  }
}
