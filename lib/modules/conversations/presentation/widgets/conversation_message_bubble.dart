import 'package:flutter/material.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
    final textColor = sentByViewer
        ? context.palette.onAction
        : context.palette.textPrimary;

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
            color: sentByViewer
                ? context.palette.action
                : context.palette.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.body,
                style: context.typography.body.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                formatConversationTime(message.sentAt),
                style: context.typography.cardSubtitle.copyWith(
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
