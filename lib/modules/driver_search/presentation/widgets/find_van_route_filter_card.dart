import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

class FindVanRouteFilterCard extends StatelessWidget {
  const FindVanRouteFilterCard({
    required this.originLabel,
    required this.destinationLabel,
    required this.onOriginTapped,
    required this.onDestinationTapped,
    required this.onSwapTapped,
    required this.dependents,
    required this.selectedDependentTokens,
    required this.onFiltersTapped,
    super.key,
  });

  final String? originLabel;
  final String? destinationLabel;
  final VoidCallback onOriginTapped;
  final VoidCallback onDestinationTapped;
  final VoidCallback onSwapTapped;
  final List<Dependent> dependents;
  final Set<String> selectedDependentTokens;
  final VoidCallback onFiltersTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteInputsBox(
            originLabel: originLabel,
            destinationLabel: destinationLabel,
            onOriginTapped: onOriginTapped,
            onDestinationTapped: onDestinationTapped,
            onSwapTapped: onSwapTapped,
          ),
          const SizedBox(height: 12),
          _FiltersButton(
            label: _filterButtonLabel(l10n),
            hasCustomSelection: _hasCustomDependentSelection,
            onTap: onFiltersTapped,
          ),
        ],
      ),
    );
  }

  bool get _hasCustomDependentSelection =>
      dependents.length > 1 &&
      selectedDependentTokens.isNotEmpty &&
      selectedDependentTokens.length < dependents.length;

  String _filterButtonLabel(AppLocalizations l10n) {
    final base = l10n.findVanFiltersButton;
    if (dependents.isEmpty) return base;
    final selected = dependents
        .where((d) => selectedDependentTokens.contains(d.token))
        .map((d) => dependentFirstName(d.name))
        .toList();
    if (selected.isEmpty ||
        (dependents.length > 1 && selected.length == dependents.length)) {
      return base;
    }
    return '$base · ${selected.join(', ')}';
  }
}

class _RouteInputsBox extends StatelessWidget {
  const _RouteInputsBox({
    required this.originLabel,
    required this.destinationLabel,
    required this.onOriginTapped,
    required this.onDestinationTapped,
    required this.onSwapTapped,
  });

  final String? originLabel;
  final String? destinationLabel;
  final VoidCallback onOriginTapped;
  final VoidCallback onDestinationTapped;
  final VoidCallback onSwapTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.cardBorder),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Column(
            children: [
              _RoutePointRow(
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.palette.card,
                    border: Border.all(
                      color: context.palette.action,
                      width: 3.5,
                    ),
                  ),
                ),
                caption: l10n.findVanOriginLabel,
                value: originLabel,
                placeholder: l10n.findVanOriginPlaceholder,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                onTap: onOriginTapped,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: context.palette.divider,
              ),
              _RoutePointRow(
                leading: Icon(
                  Icons.location_on,
                  size: 18,
                  color: context.palette.textPrimary,
                ),
                caption: l10n.findVanDestinationLabel,
                value: destinationLabel,
                placeholder: l10n.findVanDestinationPlaceholder,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
                onTap: onDestinationTapped,
              ),
            ],
          ),
          Positioned(
            right: 10,
            child: Tooltip(
              message: l10n.findVanSwapTooltip,
              child: Material(
                color: context.palette.card,
                shape: CircleBorder(
                  side: BorderSide(color: context.palette.inputBorder),
                ),
                elevation: 1,
                shadowColor: context.palette.shadow.withValues(alpha: 0.12),
                child: InkWell(
                  onTap: onSwapTapped,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 18,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePointRow extends StatelessWidget {
  const _RoutePointRow({
    required this.leading,
    required this.caption,
    required this.value,
    required this.placeholder,
    required this.borderRadius,
    required this.onTap,
  });

  final Widget leading;
  final String caption;
  final String? value;
  final String placeholder;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 50, 10),
        child: Row(
          children: [
            SizedBox(width: 20, child: Center(child: leading)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.palette.textSecondary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                      color: hasValue
                          ? context.palette.textPrimary
                          : context.palette.placeholder,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({
    required this.label,
    required this.hasCustomSelection,
    required this.onTap,
  });

  final String label;
  final bool hasCustomSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = hasCustomSelection;
    return Material(
      color: highlight ? context.palette.actionSurface : context.palette.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: highlight
              ? context.palette.actionBorder
              : context.palette.inputBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: highlight
                    ? context.palette.action
                    : context.palette.textPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: highlight
                        ? context.palette.action
                        : context.palette.textPrimary,
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
