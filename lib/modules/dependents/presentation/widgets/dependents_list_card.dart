import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_menu_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DependentsListCard extends StatelessWidget {
  const DependentsListCard({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: BorderSide(color: context.palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              Divider(height: 1, thickness: 1, color: context.palette.divider),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class DependentListRow extends StatelessWidget {
  const DependentListRow({
    required this.dependent,
    required this.isIncomplete,
    required this.onTap,
    super.key,
  });

  final Dependent dependent;
  final bool isIncomplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstName = dependentFirstName(dependent.name);
    final subtitle = dependentRowSubtitle(l10n, dependent);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            VanepInitialAvatar(name: dependent.name, seed: dependent.token),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependent.isDefault
                        ? l10n.dependentsTitleWithDefault(
                            firstName,
                            l10n.dependentsDefaultBadge,
                          )
                        : firstName,
                    style: context.typography.cardTitle.copyWith(fontSize: 15),
                  ),
                  if (isIncomplete) ...[
                    const SizedBox(height: 3),
                    VanepMenuWarningSubtitle(text: l10n.dependentsIncomplete),
                  ] else if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle, style: context.typography.cardSubtitle),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.palette.textMuted),
          ],
        ),
      ),
    );
  }
}

class DependentListRowSkeleton extends StatelessWidget {
  const DependentListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Bone.circle(size: 40),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 1, fontSize: 15),
                SizedBox(height: 4),
                Bone.text(words: 3, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
