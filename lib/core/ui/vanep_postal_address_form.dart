import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import '../domain/postal_address_draft.dart';
import '../formatters/postal_code_input_formatter.dart';
import 'vanep_cep_address_card.dart';
import 'vanep_page_chrome.dart';
import 'vanep_text_field.dart';

const vanepUfFieldWidth = 108.0;

enum PostalLocationMode { none, resolved, manual }

PostalLocationMode postalLocationModeOf(
  PostalAddressDraft draft, {
  required bool isLookingUpCep,
}) {
  if (isLookingUpCep || draft.isZipCodeUnknown) return PostalLocationMode.none;
  if (draft.isCityLocked) return PostalLocationMode.resolved;
  if (draft.zipCode.length == brazilianZipDigitCount) {
    return PostalLocationMode.manual;
  }
  return PostalLocationMode.none;
}

class VanepPostalAddressForm extends StatefulWidget {
  const VanepPostalAddressForm({
    required this.draft,
    required this.ufOptions,
    required this.onZipChanged,
    required this.onStreetChanged,
    required this.onNumberChanged,
    required this.onComplementChanged,
    required this.onNeighborhoodChanged,
    required this.onUfChanged,
    required this.onCityTap,
    this.showErrors = false,
    this.isLookingUpCep = false,
    this.zipErrorText,
    this.enabled = true,
    super.key,
  });

  final PostalAddressDraft draft;
  final List<String> ufOptions;
  final ValueChanged<String> onZipChanged;
  final ValueChanged<String> onStreetChanged;
  final ValueChanged<String> onNumberChanged;
  final ValueChanged<String> onComplementChanged;
  final ValueChanged<String> onNeighborhoodChanged;
  final ValueChanged<String> onUfChanged;
  final VoidCallback onCityTap;
  final bool showErrors;
  final bool isLookingUpCep;
  final String? zipErrorText;
  final bool enabled;

  @override
  State<VanepPostalAddressForm> createState() => VanepPostalAddressFormState();
}

class VanepPostalAddressFormState extends State<VanepPostalAddressForm> {
  late final TextEditingController zipController;
  late final TextEditingController streetController;
  late final TextEditingController numberController;
  late final TextEditingController complementController;
  late final TextEditingController neighborhoodController;
  late final TextEditingController cityController;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    zipController = TextEditingController(
      text: formatBrazilianZip(draft.zipCode),
    );
    streetController = TextEditingController(text: draft.street);
    numberController = TextEditingController(text: draft.number);
    complementController = TextEditingController(text: draft.complement);
    neighborhoodController = TextEditingController(text: draft.neighborhood);
    cityController = TextEditingController(text: draft.cityName);
  }

  @override
  void didUpdateWidget(VanepPostalAddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final draft = widget.draft;
    syncText(zipController, formatBrazilianZip(draft.zipCode));
    syncText(streetController, draft.street);
    syncText(numberController, draft.number);
    syncText(complementController, draft.complement);
    syncText(neighborhoodController, draft.neighborhood);
    syncText(cityController, draft.cityName);
  }

  @override
  void dispose() {
    zipController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void syncText(TextEditingController controller, String value) {
    if (controller.text != value) controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = widget.draft;
    final issues = draft.issues;
    final required = l10n.postalAddressFieldRequiredError;
    final mode = postalLocationModeOf(
      draft,
      isLookingUpCep: widget.isLookingUpCep,
    );
    final showsNeighborhood =
        mode == PostalLocationMode.manual ||
        (mode == PostalLocationMode.resolved && !draft.isNeighborhoodLocked);

    final zipError =
        widget.zipErrorText ??
        (widget.showErrors && issues.contains(PostalAddressIssue.zipCodeInvalid)
            ? required
            : null);
    final streetError =
        widget.showErrors && issues.contains(PostalAddressIssue.streetRequired)
        ? required
        : null;
    final ufError = widget.showErrors && draft.uf.isEmpty ? required : null;
    final cityError =
        widget.showErrors && issues.contains(PostalAddressIssue.cityRequired)
        ? required
        : null;
    final canPickCity = widget.enabled && draft.uf.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: withSpacing(<Widget>[
        VanepTextField(
          label: l10n.postalAddressFieldZip,
          isRequired: true,
          controller: zipController,
          onChanged: widget.onZipChanged,
          enabled: widget.enabled,
          hintText: l10n.postalAddressHintZip,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.postalCode],
          inputFormatters: const [PostalCodeInputFormatter()],
          isLoading: widget.isLookingUpCep,
          loadingLabel: l10n.postalAddressLookingUpCep,
          errorText: zipError,
        ),
        if (mode == PostalLocationMode.resolved)
          VanepCepAddressCard(
            neighborhood: draft.isNeighborhoodLocked ? draft.neighborhood : '',
            city: draft.cityName,
            uf: draft.uf,
          ),
        if (mode == PostalLocationMode.manual)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VanepUfSelect(
                label: l10n.postalAddressFieldUf,
                hint: l10n.postalAddressHintUf,
                value: draft.uf,
                options: widget.ufOptions,
                errorText: ufError,
                enabled: widget.enabled,
                onChanged: widget.onUfChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VanepTextField(
                  label: l10n.postalAddressFieldMunicipality,
                  isRequired: true,
                  controller: cityController,
                  onChanged: (_) {},
                  readOnly: true,
                  enabled: canPickCity,
                  hintText: draft.uf.isEmpty
                      ? l10n.postalAddressChooseUfFirst
                      : l10n.postalAddressHintCity,
                  errorText: cityError,
                  onTap: canPickCity ? widget.onCityTap : null,
                ),
              ),
            ],
          ),
        if (showsNeighborhood)
          VanepTextField(
            label: l10n.postalAddressFieldNeighborhood,
            controller: neighborhoodController,
            onChanged: widget.onNeighborhoodChanged,
            enabled: widget.enabled,
            hintText: l10n.postalAddressHintNeighborhood,
            textInputAction: TextInputAction.next,
            maxLength: PostalAddressLimits.neighborhood,
          ),
        VanepTextField(
          label: l10n.postalAddressFieldStreet,
          isRequired: true,
          controller: streetController,
          onChanged: widget.onStreetChanged,
          enabled: widget.enabled,
          hintText: l10n.postalAddressHintStreet,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.streetAddressLine1],
          maxLength: PostalAddressLimits.street,
          errorText: streetError,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: VanepTextField(
                label: l10n.postalAddressFieldNumber,
                controller: numberController,
                onChanged: widget.onNumberChanged,
                enabled: widget.enabled,
                hintText: l10n.postalAddressHintNumber,
                textInputAction: TextInputAction.next,
                maxLength: PostalAddressLimits.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: VanepTextField(
                label: l10n.postalAddressFieldComplement,
                controller: complementController,
                onChanged: widget.onComplementChanged,
                enabled: widget.enabled,
                hintText: l10n.postalAddressHintComplement,
                textInputAction: TextInputAction.done,
                maxLength: PostalAddressLimits.complement,
              ),
            ),
          ],
        ),
      ], 16),
    );
  }
}

List<String> ufMenuValues({
  required String value,
  required List<String> options,
}) {
  if (value.isNotEmpty && !options.contains(value)) return [value, ...options];
  return options;
}

class VanepUfSelect extends StatelessWidget {
  const VanepUfSelect({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String hint;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final values = ufMenuValues(value: value, options: options);
    final textStyle = VanepTypography.fieldValue.copyWith(
      color: enabled ? VanepColors.textPrimary : VanepColors.textMuted,
    );

    return SizedBox(
      width: vanepUfFieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VanepFieldLabel(label: label, isRequired: true),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: vanepInputDecoration(errorText: errorText).copyWith(
              enabled: enabled,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),
            child: enabled
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value.isEmpty ? null : value,
                      isExpanded: true,
                      menuMaxHeight: 280,
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: VanepColors.card,
                      hint: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VanepTypography.fieldValue.copyWith(
                          color: VanepColors.placeholder,
                        ),
                      ),
                      icon: const Icon(
                        Icons.expand_more,
                        size: 20,
                        color: VanepColors.textSecondary,
                      ),
                      style: textStyle,
                      items: [
                        for (final uf in values)
                          DropdownMenuItem(value: uf, child: Text(uf)),
                      ],
                      onChanged: (uf) {
                        if (uf != null) onChanged(uf);
                      },
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: kMinInteractiveDimension,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value.isEmpty ? hint : value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: value.isEmpty
                            ? VanepTypography.fieldValue.copyWith(
                                color: VanepColors.placeholder,
                              )
                            : textStyle,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
