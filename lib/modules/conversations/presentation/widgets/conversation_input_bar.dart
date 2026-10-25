import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';

class ConversationInputBar extends StatefulWidget {
  const ConversationInputBar({
    required this.isSending,
    required this.onSend,
    this.onAdjustmentTapped,
    super.key,
  });

  final bool isSending;
  final Future<bool> Function(String body) onSend;
  final VoidCallback? onAdjustmentTapped;

  @override
  State<ConversationInputBar> createState() => ConversationInputBarState();
}

class ConversationInputBarState extends State<ConversationInputBar> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> sendTypedMessage() async {
    final sent = await widget.onSend(controller.text);
    if (sent && mounted) controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onAdjustmentTapped = widget.onAdjustmentTapped;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: VanepColors.card,
        border: Border(top: BorderSide(color: VanepColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (onAdjustmentTapped != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: IconButton.outlined(
                    tooltip: l10n.conversationAdjustmentTooltip,
                    color: VanepColors.textPrimary,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: VanepColors.inputBorder),
                    ),
                    onPressed: onAdjustmentTapped,
                    icon: const Icon(Icons.tune),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: conversationMessageMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: vanepInputDecoration(
                    hintText: l10n.conversationInputHint,
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend =
                      !widget.isSending &&
                      !isBlankConversationMessage(value.text);
                  return IconButton(
                    tooltip: l10n.conversationSend,
                    color: VanepColors.action,
                    onPressed: canSend ? sendTypedMessage : null,
                    icon: const Icon(Icons.send_rounded),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
