import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_labels.dart';

class CurrentProposalBanner extends StatelessWidget {
  const CurrentProposalBanner({
    required this.proposal,
    required this.onTap,
    super.key,
  });

  final ProposalVersionEvent proposal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: VanepColors.action.withValues(alpha: 0.04),
      shape: const Border(
        top: BorderSide(color: VanepColors.cardBorder),
        bottom: BorderSide(color: VanepColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.request_quote_outlined,
                size: 20,
                color: VanepColors.action,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.conversationNegotiationBannerTitle(
                          proposal.version,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: formatProposalBannerTerms(l10n, proposal)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.conversationNegotiationBannerAction,
                style: VanepTypography.linkAction.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
