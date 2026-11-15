import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';

class AssistantConfirmedBadge extends StatelessWidget {
  const AssistantConfirmedBadge({required this.source, super.key});

  final ConfirmationSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAssistant = source == ConfirmationSource.assistant;
    final label = isAssistant
        ? l10n.assistantConfirmedByAssistant
        : l10n.assistantConfirmedByDriver;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAssistant
            ? context.palette.actionSurface
            : context.palette.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAssistant ? Icons.badge_outlined : Icons.drive_eta_outlined,
            size: 13,
            color: isAssistant
                ? context.palette.action
                : context.palette.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: context.typography.cardSubtitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAssistant
                    ? context.palette.action
                    : context.palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
