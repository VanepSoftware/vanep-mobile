import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_confirmed_badge.dart';

class AssistantStudentCard extends StatelessWidget {
  const AssistantStudentCard({
    required this.item,
    this.isSelected = false,
    this.showSelection = false,
    this.showActions = true,
    this.onToggleSelect,
    this.onConfirmBoarding,
    this.onMarkNoShow,
    super.key,
  });

  final AssistantChecklistItem item;

  final bool isSelected;

  final bool showSelection;

  final bool showActions;

  final VoidCallback? onToggleSelect;

  final VoidCallback? onConfirmBoarding;

  final VoidCallback? onMarkNoShow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSelect = showSelection &&
        (item.status == BoardingStatus.boarded ||
            item.status == BoardingStatus.pending);
    final isPending = item.status == BoardingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VanepColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? VanepColors.action : VanepColors.cardBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canSelect) ...[
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: VanepColors.action,
                    onChanged: (_) => onToggleSelect?.call(),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              _StudentAvatar(name: item.studentName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      style: VanepTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.schoolName,
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: item.status, l10n: l10n),
            ],
          ),
          if (item.confirmedBy != null) ...[
            const SizedBox(height: 10),
            AssistantConfirmedBadge(source: item.confirmedBy!),
          ],
          if (showActions && isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: OutlinedButton(
                      onPressed: onMarkNoShow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VanepColors.danger,
                        side: const BorderSide(color: VanepColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.assistantMarkNoShow,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: ElevatedButton(
                      onPressed: onConfirmBoarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VanepColors.action,
                        foregroundColor: VanepColors.onBrand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.assistantConfirmBoarding,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: VanepColors.avatarPlaceholder,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: VanepTypography.cardTitle.copyWith(
          color: VanepColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.l10n,
  });

  final BoardingStatus status;

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      BoardingStatus.pending => (
        l10n.assistantStatusPending,
        VanepColors.warningSurface,
        VanepColors.warning,
      ),
      BoardingStatus.boarded => (
        l10n.assistantStatusBoarded,
        VanepColors.actionSurface,
        VanepColors.action,
      ),
      BoardingStatus.droppedOff => (
        l10n.assistantStatusDroppedOff,
        const Color(0x1F1E8E5A),
        VanepColors.success,
      ),
      BoardingStatus.noShow => (
        l10n.assistantStatusNoShow,
        const Color(0x1FC4564A),
        VanepColors.danger,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
