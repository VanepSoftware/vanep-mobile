import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class DriverAdjustmentFooter extends StatelessWidget {
  const DriverAdjustmentFooter({
    required this.onKeepCurrent,
    required this.onNewVersion,
    required this.onEndNegotiation,
    super.key,
  });

  // Keeping the current version has no endpoint: the driver tells the family in
  // the chat, so there is nothing to offer without a conversation.
  final VoidCallback? onKeepCurrent;
  final VoidCallback onNewVersion;
  final VoidCallback onEndNegotiation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onKeepCurrent = this.onKeepCurrent;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: context.palette.card,
          border: Border(top: BorderSide(color: context.palette.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (onKeepCurrent != null) ...[
                  Expanded(
                    child: VanepSecondaryButton(
                      label: l10n.driverAdjustmentKeepCurrent,
                      onPressed: onKeepCurrent,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: VanepPrimaryButton(
                    label: l10n.driverProposalsNewVersion,
                    onPressed: onNewVersion,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            VanepSecondaryButton(
              label: l10n.driverAdjustmentEndNegotiation,
              isDestructive: true,
              onPressed: onEndNegotiation,
            ),
          ],
        ),
      ),
    );
  }
}
