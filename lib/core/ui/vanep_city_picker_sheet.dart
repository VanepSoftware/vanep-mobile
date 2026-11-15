import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const vanepCityPickerMaxHeight = 360.0;
const vanepCitySearchMinLength = 2;
const vanepCitySearchDebounce = Duration(milliseconds: 300);

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
    backgroundColor: context.palette.card,
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

class VanepCityPickerSheet extends StatefulWidget {
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

  @override
  State<VanepCityPickerSheet> createState() => _VanepCityPickerSheetState();
}

class _VanepCityPickerSheetState extends State<VanepCityPickerSheet> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void handleSearch(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isNotEmpty && query.length < vanepCitySearchMinLength) return;
    _debounce = Timer(vanepCitySearchDebounce, () {
      widget.onSearchChanged(query);
    });
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
              style: context.typography.cardTitle,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: handleSearch,
              autofocus: true,
              textInputAction: TextInputAction.search,
              cursorColor: context.palette.action,
              style: context.typography.fieldValue,
              decoration: vanepInputDecoration(
                context,
                hintText: l10n.postalAddressCitySearchHint,
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 12),
            CityPickerResults(
              options: widget.options,
              selectedToken: widget.selectedToken,
              errorText: widget.errorText,
              onSelected: widget.onSelected,
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
          style: context.typography.cardSubtitle.copyWith(
            color: context.palette.danger,
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
            style: context.typography.cardSubtitle,
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
            Divider(height: 1, color: context.palette.divider),
        itemBuilder: (context, index) {
          final option = options[index];
          return InkWell(
            onTap: () => onSelected(option),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.name,
                      style: context.typography.fieldValue,
                    ),
                  ),
                  if (option.token == selectedToken)
                    Icon(Icons.check, color: context.palette.action, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
