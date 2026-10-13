import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';

class DriverConversationTile extends StatelessWidget {
  const DriverConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final Conversation conversation;
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
              conversation.clientName,
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
