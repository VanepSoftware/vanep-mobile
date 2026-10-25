import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_labels.dart';

class ChatDayChip extends StatelessWidget {
  const ChatDayChip({required this.day, super.key});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: VanepColors.divider,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          formatChatDay(l10n, day),
          style: VanepTypography.cardSubtitle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ChatPrivacyNoticeText extends StatelessWidget {
  const ChatPrivacyNoticeText({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
        child: Text(
          l10n.conversationNegotiationPrivacyNotice,
          textAlign: TextAlign.center,
          style: VanepTypography.cardSubtitle.copyWith(
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class ChatAgreementNoticeBox extends StatelessWidget {
  const ChatAgreementNoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: VanepColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: VanepColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: VanepColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.conversationNegotiationAgreementNotice,
              style: VanepTypography.cardSubtitle.copyWith(
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
