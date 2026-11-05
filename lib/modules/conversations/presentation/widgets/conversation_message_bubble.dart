import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';

class ConversationMessageBubble extends StatelessWidget {
  const ConversationMessageBubble({
    required this.message,
    required this.sentByViewer,
    super.key,
  });

  final ConversationMessage message;
  final bool sentByViewer;

  @override
  Widget build(BuildContext context) {
    final textColor = sentByViewer ? VanepColors.card : VanepColors.textPrimary;

    return Align(
      alignment: sentByViewer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: sentByViewer ? VanepColors.action : VanepColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.body,
                style: VanepTypography.body.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                formatConversationTime(message.sentAt),
                style: VanepTypography.cardSubtitle.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
