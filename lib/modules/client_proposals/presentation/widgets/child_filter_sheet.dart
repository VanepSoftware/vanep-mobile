import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';

Future<void> showChildFilterSheet(
  BuildContext context, {
  required ClientProposals proposals,
  required String? selectedChildToken,
  required ValueChanged<String?> onChildSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VanepColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => ChildFilterSheet(
      proposals: proposals,
      selectedChildToken: selectedChildToken,
      onChildSelected: (childToken) {
        onChildSelected(childToken);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

class ChildFilterSheet extends StatelessWidget {
  const ChildFilterSheet({
    required this.proposals,
    required this.selectedChildToken,
    required this.onChildSelected,
    super.key,
  });

  final ClientProposals proposals;
  final String? selectedChildToken;
  final ValueChanged<String?> onChildSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <Widget>[
      ChildFilterOption(
        avatar: const VanepAvatar(
          size: 40,
          placeholderIcon: Icons.groups,
          backgroundColor: VanepColors.brandNavy,
          foregroundColor: VanepColors.onBrand,
        ),
        title: l10n.clientProposalsAllChildren,
        subtitle: l10n.clientProposalsOpenCount(proposals.openRequestsCount),
        isSelected: selectedChildToken == null,
        onTap: () => onChildSelected(null),
      ),
      for (final child in proposals.children)
        ChildFilterOption(
          avatar: VanepPersonAvatar(name: child.name),
          title: child.name,
          titleDetail: formatChildAge(l10n, child, proposals.loadedAt),
          subtitle: formatChildOpenSummary(
            l10n,
            proposals.feedFor(child.token),
          ),
          isSelected: selectedChildToken == child.token,
          onTap: () => onChildSelected(child.token),
        ),
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VanepColors.inputBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.clientProposalsFilterSheetTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: VanepColors.textPrimary,
                      ),
                    ),
                  ),
                  const CloseButton(),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final (index, option) in options.indexed) ...[
                        if (index > 0) const Divider(),
                        option,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildFilterOption extends StatelessWidget {
  const ChildFilterOption({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.titleDetail,
    super.key,
  });

  final Widget avatar;
  final String title;
  final String? titleDetail;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleDetail = this.titleDetail;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: title,
                          style: VanepTypography.cardTitle.copyWith(
                            fontSize: 15,
                          ),
                          children: [
                            if (titleDetail != null)
                              TextSpan(
                                text: ' · $titleDetail',
                                style: VanepTypography.cardSubtitle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(subtitle, style: VanepTypography.cardSubtitle),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ChildFilterRadio(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChildFilterRadio extends StatelessWidget {
  const ChildFilterRadio({required this.isSelected, super.key});

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
