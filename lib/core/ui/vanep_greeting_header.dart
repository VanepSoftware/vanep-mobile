import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

String firstNameOf(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.split(RegExp(r'\s+')).first;
}

class VanepGreetingHeader extends StatelessWidget {
  const VanepGreetingHeader({
    required this.displayName,
    this.subtitle,
    this.trailingEmoji,
    super.key,
  });

  final String displayName;
  final String? subtitle;
  final String? trailingEmoji;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = l10n.homeGreeting(firstNameOf(displayName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(greeting, style: VanepTypography.pageTitle),
            ),
            if (trailingEmoji != null) ...[
              const SizedBox(width: 8),
              Text(trailingEmoji!, style: VanepTypography.pageTitle),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: VanepTypography.cardSubtitle.copyWith(
              color: VanepColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
