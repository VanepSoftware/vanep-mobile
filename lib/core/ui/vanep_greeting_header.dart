import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepGreetingHeader extends StatelessWidget {
  const VanepGreetingHeader({
    required this.displayName,
    this.title,
    this.subtitle,
    this.trailingEmoji,
    super.key,
  });

  final String displayName;
  final String? title;
  final String? subtitle;
  final String? trailingEmoji;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = title ?? l10n.homeGreeting(firstNameOf(displayName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(greeting, style: context.typography.pageTitle),
            ),
            if (trailingEmoji != null) ...[
              const SizedBox(width: 8),
              Text(trailingEmoji!, style: context.typography.pageTitle),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: context.typography.cardSubtitle.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
