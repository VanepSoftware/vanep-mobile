import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import '../places/place_autocomplete_controller.dart';
import '../places/place_autocomplete_failure.dart';
import '../places/place_suggestion.dart';
import '../result/result.dart';

class PlaceSelection {
  const PlaceSelection({required this.suggestion, required this.sessionToken});

  final PlaceSuggestion suggestion;

  final String sessionToken;
}

class VanepPlaceAutocompleteField extends StatefulWidget {
  const VanepPlaceAutocompleteField({
    required this.controller,
    required this.hint,
    required this.onSelected,
    required this.emptyLabel,
    required this.networkErrorLabel,
    required this.keyErrorLabel,
    required this.retryLabel,
    this.enabled = true,
    this.clearOnSelect = true,
    super.key,
  });

  final PlaceAutocompleteController controller;
  final String hint;
  final ValueChanged<PlaceSelection> onSelected;
  final String emptyLabel;
  final String networkErrorLabel;
  final String keyErrorLabel;
  final String retryLabel;
  final bool enabled;

  /// Limpar faz sentido quando a seleção vira um item numa lista e o campo é
  /// reaproveitado para o próximo. Numa busca, apagar o que a pessoa acabou de
  /// escolher esconde o que ela pesquisou e faz a tela parecer quebrada.
  final bool clearOnSelect;

  @override
  State<VanepPlaceAutocompleteField> createState() =>
      VanepPlaceAutocompleteFieldState();
}

class VanepPlaceAutocompleteFieldState
    extends State<VanepPlaceAutocompleteField> {
  final TextEditingController textController = TextEditingController();

  List<PlaceSuggestion> suggestions = const [];
  PlaceAutocompleteFailure? failure;
  bool searched = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void onQueryChanged(String value) {
    widget.controller.search(value, applyResult);
  }

  void applyResult(
    Result<PlaceAutocompleteFailure, List<PlaceSuggestion>> result,
  ) {
    if (!mounted) return;
    setState(() {
      searched = textController.text.trim().isNotEmpty;
      failure = result.errorOrNull;
      suggestions = result.valueOrNull ?? const [];
    });
  }

  void selectSuggestion(PlaceSuggestion suggestion) {
    final sessionToken = widget.controller.handOverSelection();
    textController.text = widget.clearOnSelect ? '' : suggestion.primaryText;
    setState(() {
      suggestions = const [];
      searched = false;
      failure = null;
    });
    widget.onSelected(
      PlaceSelection(suggestion: suggestion, sessionToken: sessionToken),
    );
  }

  String? get failureLabel {
    return switch (failure) {
      PlaceAutocompleteFailure.rejectedKey => widget.keyErrorLabel,
      PlaceAutocompleteFailure.network ||
      PlaceAutocompleteFailure.unexpected => widget.networkErrorLabel,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final message = failureLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: textController,
          enabled: widget.enabled,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          style: VanepTypography.cardSubtitle.copyWith(
            color: VanepColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: VanepColors.searchField,
            hintText: widget.hint,
            hintStyle: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
            prefixIcon: const Icon(
              Icons.search,
              color: VanepColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: VanepColors.brand,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onQueryChanged(textController.text),
                  child: Text(widget.retryLabel),
                ),
              ],
            ),
          ),
        if (message == null && searched && suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.emptyLabel,
              style: VanepTypography.cardSubtitle,
            ),
          ),
        for (final suggestion in suggestions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              suggestion.primaryText,
              style: VanepTypography.cardTitle,
            ),
            subtitle: suggestion.secondaryText.isEmpty
                ? null
                : Text(
                    suggestion.secondaryText,
                    style: VanepTypography.cardSubtitle,
                  ),
            onTap: () => selectSuggestion(suggestion),
          ),
      ],
    );
  }
}
