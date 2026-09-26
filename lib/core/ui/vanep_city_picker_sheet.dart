import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import 'vanep_text_field.dart';

const vanepCityPickerMaxHeight = 360.0;
const vanepCitySearchMinLength = 2;

class VanepCityOption extends Equatable {
  const VanepCityOption({required this.token, required this.name});

  final String token;
  final String name;

  @override
  List<Object?> get props => [token, name];
}

Future<void> showVanepCityPickerSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VanepColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}

class VanepCityPickerSheet extends StatelessWidget {
  const VanepCityPickerSheet({
    required this.options,
    required this.onSearchChanged,
    required this.onSelected,
    this.selectedToken,
    this.errorText,
    super.key,
  });

  final List<VanepCityOption> options;
  final String? selectedToken;
  final String? errorText;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VanepCityOption> onSelected;

  void handleSearch(String value) {
    final query = value.trim();
    if (query.length >= vanepCitySearchMinLength || query.isEmpty) {
      onSearchChanged(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.postalAddressCityPickerTitle,
              style: VanepTypography.cardTitle,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: handleSearch,
              autofocus: true,
              textInputAction: TextInputAction.search,
              cursorColor: VanepColors.action,
              style: VanepTypography.fieldValue,
              decoration: vanepInputDecoration(
                hintText: l10n.postalAddressCitySearchHint,
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 12),
            CityPickerResults(
              options: options,
              selectedToken: selectedToken,
              errorText: errorText,
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class CityPickerResults extends StatelessWidget {
  const CityPickerResults({
    required this.options,
    required this.onSelected,
    this.selectedToken,
    this.errorText,
    super.key,
  });

  final List<VanepCityOption> options;
  final String? selectedToken;
  final String? errorText;
  final ValueChanged<VanepCityOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = errorText;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          error,
          style: VanepTypography.cardSubtitle.copyWith(
            color: VanepColors.danger,
          ),
        ),
      );
    }
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            l10n.postalAddressNoCitiesFound,
            style: VanepTypography.cardSubtitle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: vanepCityPickerMaxHeight),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: VanepColors.divider),
        itemBuilder: (context, index) {
          final option = options[index];
          return InkWell(
            onTap: () => onSelected(option),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(option.name, style: VanepTypography.fieldValue),
                  ),
                  if (option.token == selectedToken)
                    const Icon(
                      Icons.check,
                      color: VanepColors.action,
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
