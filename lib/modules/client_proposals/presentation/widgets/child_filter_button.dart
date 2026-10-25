import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

const filterButtonVisibleAvatars = 2;

class ChildFilterButton extends StatelessWidget {
  const ChildFilterButton({
    required this.children,
    required this.selectedChild,
    required this.onTap,
    super.key,
  });

  final List<ProposalChild> children;
  final ProposalChild? selectedChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedChild = this.selectedChild;
    final label = selectedChild?.name ?? l10n.clientProposalsAllChildren;
    final names = selectedChild != null
        ? [selectedChild.name]
        : children.take(filterButtonVisibleAvatars).map((child) => child.name);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: l10n.clientProposalsFilterByChild(label),
        excludeSemantics: true,
        child: Material(
          color: VanepColors.card,
          shape: const StadiumBorder(
            side: BorderSide(color: VanepColors.inputBorder),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 12, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VanepAvatarStack(
                      names: names.toList(),
                      hiddenCount: selectedChild == null
                          ? children.length - names.length
                          : 0,
                      size: 32,
                      step: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: VanepColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 20,
                      color: VanepColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
