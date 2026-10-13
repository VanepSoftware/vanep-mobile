import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';

class ConversationInboxTile extends StatelessWidget {
  const ConversationInboxTile({
    required this.conversation,
    required this.viewerSide,
    required this.onTap,
    super.key,
  });

  final Conversation conversation;
  final ConversationParticipant viewerSide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastMessageAt = conversation.lastMessageAt;

    return VanepCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const VanepAvatar(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              conversationCounterpartName(conversation, viewerSide),
              style: VanepTypography.cardTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageAt != null)
            Text(
              formatConversationListTime(lastMessageAt),
              style: VanepTypography.cardSubtitle,
            ),
        ],
      ),
    );
  }
}
