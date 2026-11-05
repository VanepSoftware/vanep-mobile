import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const proposalsSectionSpacing = 16.0;

const proposalsCardSpacing = 12.0;

Future<void> openUnavailableProposalAction(BuildContext context, String title) {
  return openComingSoonPage(
    context,
    title: title,
    message: AppLocalizations.of(context)!.comingSoon,
  );
}

class ProposalsSectionTitle extends StatelessWidget {
  const ProposalsSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: proposalsCardSpacing),
      child: Text(title, style: VanepTypography.sectionTitle),
    );
  }
}

class ProposalPersonHeader extends StatelessWidget {
  const ProposalPersonHeader({
    required this.avatar,
    required this.name,
    required this.subtitle,
    this.subtitleLeading,
    this.trailing,
    super.key,
  });

  final Widget avatar;
  final String name;
  final String subtitle;
  final Widget? subtitleLeading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleLeading = this.subtitleLeading;
    final trailing = this.trailing;
    return Row(
      children: [
        avatar,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: VanepTypography.cardTitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (subtitleLeading != null) ...[
                    subtitleLeading,
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(subtitle, style: VanepTypography.cardSubtitle),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }
}

class ProposalStatusText extends StatelessWidget {
  const ProposalStatusText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: VanepTypography.cardSubtitle.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
