import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

class ProposalMessageSection extends StatefulWidget {
  const ProposalMessageSection({
    required this.message,
    required this.onMessageChanged,
    super.key,
  });

  final String message;
  final ValueChanged<String>? onMessageChanged;

  @override
  State<ProposalMessageSection> createState() => ProposalMessageSectionState();
}

class ProposalMessageSectionState extends State<ProposalMessageSection> {
  late final controller = TextEditingController(text: widget.message);

  @override
  void didUpdateWidget(ProposalMessageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.text != widget.message) controller.text = widget.message;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(
          title: l10n.driverProposalMessageLabel,
          titleDetail: l10n.driverProposalOptional,
        ),
        TextField(
          controller: controller,
          enabled: widget.onMessageChanged != null,
          onChanged: widget.onMessageChanged,
          minLines: 3,
          maxLines: 5,
          maxLength: proposalMessageMaxLength,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: VanepColors.action,
          style: VanepTypography.body.copyWith(fontSize: 14),
          decoration: vanepInputDecoration(
            hintText: l10n.driverProposalMessageHint,
          ),
        ),
      ],
    );
  }
}

class ProposalValidityNote extends StatelessWidget {
  const ProposalValidityNote({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = VanepTypography.cardSubtitle.copyWith(fontSize: 12);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: VanepColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(l10n.driverProposalValidity(days), style: style),
        ),
      ],
    );
  }
}

class ProposalSendBar extends StatelessWidget {
  const ProposalSendBar({
    required this.draft,
    required this.isSending,
    required this.onSend,
    super.key,
  });

  final ProposalComposeDraft draft;
  final bool isSending;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepBottomBar(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatMoney(l10n, draft.familyTotalCents),
                    style: VanepTypography.cardTitle.copyWith(fontSize: 20),
                  ),
                ),
                Text(
                  formatInstallmentAmount(
                    l10n,
                    installments: draft.payment.installments,
                    monthlyCents: draft.monthlyFamilyCents,
                  ),
                  style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: VanepPrimaryButton(
              label: l10n.driverProposalSend,
              leadingIcon: Icons.send_outlined,
              isLoading: isSending,
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class ProposalComposeNotice extends StatelessWidget {
  const ProposalComposeNotice({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VanepColors.warningSurface,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(color: VanepColors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VanepTypography.cardTitle),
          const SizedBox(height: 4),
          Text(message, style: VanepTypography.body),
        ],
      ),
    );
  }
}

class ProposalComposeSkeleton extends StatelessWidget {
  const ProposalComposeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 1, fontSize: 15),
          SizedBox(height: 10),
          VanepCard(child: Bone(height: 24, width: double.infinity)),
          SizedBox(height: 20),
          Bone.text(words: 3, fontSize: 15),
          SizedBox(height: 10),
          VanepCard(child: Bone(height: 120, width: double.infinity)),
          SizedBox(height: 16),
          VanepCard(child: Bone(height: 140, width: double.infinity)),
        ],
      ),
    );
  }
}
