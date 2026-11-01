import 'package:flutter/widgets.dart';

import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

Future<bool> confirmProposalAcceptance(
  BuildContext context,
  ClientServiceRequest request,
) {
  final l10n = AppLocalizations.of(context)!;
  return showVanepConfirmDialog(
    context: context,
    title: l10n.proposalAcceptConfirmTitle,
    message: l10n.proposalAcceptConfirmMessage(
      formatRequestChildren(l10n, request),
      request.driverName,
    ),
    confirmLabel: l10n.proposalDetailAccept,
    cancelLabel: l10n.proposalConfirmBack,
  );
}
