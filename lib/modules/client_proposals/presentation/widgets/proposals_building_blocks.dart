import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

const proposalsSectionSpacing = 16.0;

const proposalsCardSpacing = 12.0;

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
    this.subtitle,
    this.subtitleLeading,
    this.trailing,
    super.key,
  });

  final Widget avatar;
  final String name;
  final String? subtitle;
  final Widget? subtitleLeading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
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
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (subtitleLeading != null) ...[
                      subtitleLeading,
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        subtitle,
                        style: VanepTypography.cardSubtitle,
                      ),
                    ),
                  ],
                ),
              ],
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

class ProposalLinkButton extends StatelessWidget {
  const ProposalLinkButton({
    required this.label,
    required this.onPressed,
    this.color = VanepColors.action,
    this.showsChevron = false,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool showsChevron;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon case final icon?) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: VanepTypography.linkAction.copyWith(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
          if (showsChevron) const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}

class ProposalDriverHeader extends StatelessWidget {
  const ProposalDriverHeader({
    required this.request,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final ClientServiceRequest request;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final rating = request.driverRating;
    return ProposalPersonHeader(
      avatar: VanepPersonAvatar(name: request.driverName),
      name: request.driverName,
      subtitle:
          subtitle ??
          (rating == null
              ? null
              : formatProposalRating(AppLocalizations.of(context)!, rating)),
      subtitleLeading: subtitle == null && rating != null
          ? const Icon(
              Icons.star_rounded,
              size: 15,
              color: VanepColors.ratingStar,
            )
          : null,
      trailing: trailing,
    );
  }
}
