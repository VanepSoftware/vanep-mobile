import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const weekLegsLabelWidth = 52.0;

const weekLegsCellSize = 30.0;

const weekLegsTapHeight = 44.0;

class VanepWeekLegCell {
  const VanepWeekLegCell({required this.isSelected, this.isEnabled = true});

  static const notAllowed = VanepWeekLegCell(
    isSelected: false,
    isEnabled: false,
  );

  final bool isSelected;

  final bool isEnabled;
}

class VanepWeekLegsRow<T> {
  const VanepWeekLegsRow({
    required this.leg,
    required this.label,
    required this.cells,
  });

  final T leg;

  final String label;

  final Map<Weekday, VanepWeekLegCell> cells;

  VanepWeekLegCell cellOn(Weekday day) =>
      cells[day] ?? VanepWeekLegCell.notAllowed;
}

List<Weekday> weekLegsColumns<T>(List<VanepWeekLegsRow<T>> rows) {
  final daysWithCells = {for (final row in rows) ...row.cells.keys};
  return [
    for (final day in Weekday.values)
      if (weekdaysMondayToFriday.contains(day) || daysWithCells.contains(day))
        day,
  ];
}

class VanepWeekLegsGrid<T> extends StatelessWidget {
  const VanepWeekLegsGrid({required this.rows, this.onToggled, super.key});

  final List<VanepWeekLegsRow<T>> rows;

  final void Function(T leg, Weekday day)? onToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final columns = weekLegsColumns(rows);
    final onToggled = this.onToggled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              const SizedBox(width: weekLegsLabelWidth),
              for (final day in columns)
                Expanded(
                  child: Text(
                    weekdayShortLabel(l10n, day),
                    textAlign: TextAlign.center,
                    style: context.typography.cardSubtitle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (final row in rows)
          Row(
            children: [
              SizedBox(
                width: weekLegsLabelWidth,
                child: ExcludeSemantics(
                  child: Text(
                    row.label,
                    style: context.typography.cardSubtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
              ),
              for (final day in columns)
                Expanded(
                  child: WeekLegCellButton(
                    label: l10n.weekLegsCellLabel(
                      weekdayLabel(l10n, day),
                      row.label,
                    ),
                    cell: row.cellOn(day),
                    onTap: onToggled == null
                        ? null
                        : () => onToggled(row.leg, day),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class WeekLegCellButton extends StatelessWidget {
  const WeekLegCellButton({
    required this.label,
    required this.cell,
    this.onTap,
    super.key,
  });

  final String label;

  final VanepWeekLegCell cell;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final isEditable = onTap != null;
    final canToggle = isEditable && cell.isEnabled;

    return Semantics(
      label: label,
      toggled: cell.isSelected,
      button: isEditable ? true : null,
      enabled: isEditable ? cell.isEnabled : null,
      excludeSemantics: true,
      onTap: canToggle ? onTap : null,
      child: InkWell(
        onTap: canToggle ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: weekLegsTapHeight,
          child: Center(child: WeekLegCellMark(cell: cell)),
        ),
      ),
    );
  }
}

class WeekLegCellMark extends StatelessWidget {
  const WeekLegCellMark({required this.cell, super.key});

  final VanepWeekLegCell cell;

  @override
  Widget build(BuildContext context) {
    final (background, border) = switch (cell) {
      VanepWeekLegCell(isSelected: true) => (
        context.palette.action,
        context.palette.action,
      ),
      VanepWeekLegCell(isEnabled: false) => (
        context.palette.surface,
        context.palette.surface,
      ),
      _ => (context.palette.card, context.palette.inputBorder),
    };
    return Container(
      width: weekLegsCellSize,
      height: weekLegsCellSize,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
      ),
      child: cell.isSelected
          ? const Icon(Icons.check, size: 18, color: VanepColors.onBrand)
          : null,
    );
  }
}
