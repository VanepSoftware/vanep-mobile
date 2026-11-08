import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_link_button.dart';

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

typedef ProposalLinkButton = VanepLinkButton;

class ProposalTermsBox extends StatelessWidget {
  const ProposalTermsBox({required this.lines, super.key});

  final List<(IconData, String)> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VanepColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, (icon, text)) in lines.indexed) ...[
            if (index > 0) const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 17, color: VanepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProposalChoiceOption extends StatelessWidget {
  const ProposalChoiceOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: VanepColors.textPrimary,
                  ),
                ),
              ),
              ProposalChoiceRadio(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class ProposalChoiceRadio extends StatelessWidget {
  const ProposalChoiceRadio({required this.isSelected, super.key});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? VanepColors.action : VanepColors.textMuted,
          width: 2,
        ),
      ),
      child: isSelected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                color: VanepColors.action,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
