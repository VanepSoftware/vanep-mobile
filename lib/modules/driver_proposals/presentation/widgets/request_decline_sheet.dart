import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/decline_reason.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class RequestDeclineSheet extends StatefulWidget {
  const RequestDeclineSheet({required this.request, super.key});

  final DriverServiceRequest request;

  @override
  State<RequestDeclineSheet> createState() => RequestDeclineSheetState();
}

class RequestDeclineSheetState extends State<RequestDeclineSheet> {
  final reason = TextEditingController();

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  void onStateChanged(BuildContext context, RequestDeclineState state) {
    final l10n = AppLocalizations.of(context)!;
    final failure = state.failure;
    if (state.declinedRequest != null) {
      VanepFeedback.showInfo(context, l10n.driverRequestDeclined);
      Navigator.of(context).pop(RequestDeclineOutcome.declined);
    } else if (failure != null) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
      if (isNegotiationOutdated(failure)) {
        Navigator.of(context).pop(RequestDeclineOutcome.outdated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RequestDeclineCubit>();

    return BlocConsumer<RequestDeclineCubit, RequestDeclineState>(
      listenWhen: (previous, current) =>
          current.declinedRequest != previous.declinedRequest ||
          current.failure != previous.failure,
      listener: onStateChanged,
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.driverRequestDeclineTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                DetailNotice(
                  text: l10n.driverRequestDeclineMessage(
                    widget.request.clientFirstName,
                  ),
                ),
                const SizedBox(height: detailSectionSpacing),
                VanepTextField(
                  label: l10n.proposalDeclineReasonTitle,
                  controller: reason,
                  hintText: l10n.proposalAdjustmentOptional,
                  maxLength: declineReasonMaxLength,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: cubit.changeReason,
                ),
                const SizedBox(height: detailSectionSpacing),
                VanepPrimaryButton(
                  label: l10n.driverRequestDeclineConfirm,
                  isLoading: state.isSending,
                  onPressed: state.canSend ? cubit.send : null,
                ),
                const SizedBox(height: 8),
                VanepSecondaryButton(
                  label: l10n.clientProposalsCancelKeep,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
