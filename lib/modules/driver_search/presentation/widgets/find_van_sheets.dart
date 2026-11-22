import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';

String sortOrderLabel(AppLocalizations l10n, DriverSearchSortOrder order) {
  return switch (order) {
    DriverSearchSortOrder.nearest => l10n.findVanSortNearest,
    DriverSearchSortOrder.highestRating => l10n.findVanSortRating,
    DriverSearchSortOrder.lowestPrice => l10n.findVanSortPrice,
    DriverSearchSortOrder.mostExperienced => l10n.findVanSortExperience,
  };
}

Future<void> _showKeyboardSafeSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final maxHeight = (media.size.height - media.padding.top) * 0.92;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: builder(sheetContext),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showFindVanPlaceSheet(
  BuildContext context, {
  required bool isDestination,
  required PlaceAutocompleteController autocomplete,
  required ValueChanged<PlaceSelection> onSelected,
  bool hasActiveSearch = false,
  VoidCallback? onClearSearch,
  String? registeredOriginLabel,
  VoidCallback? onUseRegisteredOrigin,
}) {
  final l10n = AppLocalizations.of(context)!;

  return _showKeyboardSafeSheet(
    context,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isDestination
                      ? l10n.findVanSearchSheetTitleDestination
                      : l10n.findVanSearchSheetTitleOrigin,
                  style: sheetContext.typography.heading.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              if (hasActiveSearch && onClearSearch != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onClearSearch();
                  },
                  child: Text(l10n.findVanClearSearch),
                ),
            ],
          ),
          if (!isDestination &&
              registeredOriginLabel != null &&
              onUseRegisteredOrigin != null) ...[
            const SizedBox(height: 10),
            Material(
              color: sheetContext.palette.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onUseRegisteredOrigin();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 20,
                        color: sheetContext.palette.action,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.findVanUseMyAddress,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: sheetContext.palette.action,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              registeredOriginLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sheetContext.typography.cardSubtitle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          VanepPlaceAutocompleteField(
            controller: autocomplete,
            clearOnSelect: false,
            hint: l10n.driverSearchHint,
            emptyLabel: l10n.placeAutocompleteNoResults,
            networkErrorLabel: l10n.placeAutocompleteNetworkError,
            keyErrorLabel: l10n.placeAutocompleteKeyError,
            retryLabel: l10n.placeAutocompleteRetry,
            onSelected: (selection) {
              Navigator.of(sheetContext).pop();
              onSelected(selection);
            },
          ),
        ],
      );
    },
  );
}

Future<void> showFindVanFilterSheet(
  BuildContext context, {
  required DriverSearchCubit cubit,
}) {
  return _showKeyboardSafeSheet(
    context,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      return BlocProvider<DriverSearchCubit>.value(
        value: cubit,
        child: BlocBuilder<DriverSearchCubit, DriverSearchState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.palette.inputBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.findVanFiltersSheetTitle,
                        style: context.typography.heading.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.navDependents,
                  style: context.typography.sectionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.findVanFiltersDependentSubtitle,
                  style: context.typography.cardSubtitle,
                ),
                const SizedBox(height: 12),
                if (state.dependents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.findVanFiltersNoDependents,
                      style: context.typography.cardSubtitle,
                    ),
                  )
                else
                  for (final dependent in state.dependents) ...[
                    _FilterDependentTile(
                      dependent: dependent,
                      selected: state.selectedDependentTokens.contains(
                        dependent.token,
                      ),
                      onTap: () => cubit.toggleDependent(dependent.token),
                    ),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 8),
                VanepPrimaryButton(
                  label: l10n.findVanFiltersApply,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _FilterDependentTile extends StatelessWidget {
  const _FilterDependentTile({
    required this.dependent,
    required this.selected,
    required this.onTap,
  });

  final Dependent dependent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final age = findAgeInYears(dependent.birthDate);
    final school = dependent.school?.name.trim();
    final subtitleParts = [
      if (age != null) l10n.dependentsAgeYears(age),
      if (school != null && school.isNotEmpty) school,
    ];

    return Material(
      color: selected ? context.palette.actionSurface : context.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? context.palette.actionBorder
              : context.palette.cardBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              VanepPersonAvatar(name: dependent.name, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dependent.name,
                      style: context.typography.cardTitle.copyWith(
                        fontSize: 14.5,
                      ),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.cardSubtitle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected
                    ? context.palette.action
                    : context.palette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showFindVanSortSheet(
  BuildContext context, {
  required DriverSearchSortOrder current,
  required ValueChanged<DriverSearchSortOrder> onSelected,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.findVanSortSheetTitle,
                style: sheetContext.typography.heading.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              for (final order in DriverSearchSortOrder.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    sortOrderLabel(l10n, order),
                    style: sheetContext.typography.body.copyWith(
                      fontWeight: order == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: order == current
                          ? sheetContext.palette.action
                          : sheetContext.palette.textPrimary,
                    ),
                  ),
                  trailing: order == current
                      ? Icon(
                          Icons.check_rounded,
                          color: sheetContext.palette.action,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(order);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showFindVanInviteSheet(
  BuildContext context, {
  ValueChanged<String>? onInviteSubmitted,
}) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  return _showKeyboardSafeSheet(
    context,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.findVanHaveInviteTitle,
            style: sheetContext.typography.heading.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.findVanHaveInviteSubtitle,
            style: sheetContext.typography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: vanepInputDecoration(
              sheetContext,
              hintText: l10n.findVanHaveInviteHint,
              prefixIcon: Icons.qr_code_2_rounded,
            ),
          ),
          const SizedBox(height: 16),
          VanepPrimaryButton(
            label: l10n.findVanHaveInviteAction,
            onPressed: () {
              final code = controller.text.trim();
              Navigator.of(sheetContext).pop();
              if (code.isNotEmpty) {
                onInviteSubmitted?.call(code);
              }
            },
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}
