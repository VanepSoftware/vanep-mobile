import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_map_placeholder.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_editor_frame.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependents_list_card.dart';

Future<Dependent?> openDependentSchool(
  BuildContext context, {
  required Dependent dependent,
}) {
  return Navigator.of(context).push<Dependent>(
    MaterialPageRoute<Dependent>(
      builder: (_) => DependentSchoolPage(dependent: dependent),
    ),
  );
}

class DependentSchoolPage extends StatelessWidget {
  const DependentSchoolPage({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<DependentSchoolCubit>(param1: dependent),
      child: DependentEditorFrame(
        title: l10n.dependentRowSchool,
        caption: dependentFirstName(dependent.name),
        body: const DependentSchoolBody(),
        bottomBar:
            DependentEditorSaveBar<DependentSchoolCubit, DependentSchoolState>(
              label: l10n.dependentEditorSave,
              onSaved: (state) => Navigator.of(context).pop(state.saved),
            ),
      ),
    );
  }
}

class DependentSchoolBody extends StatefulWidget {
  const DependentSchoolBody({super.key});

  @override
  State<DependentSchoolBody> createState() => DependentSchoolBodyState();
}

class DependentSchoolBodyState extends State<DependentSchoolBody> {
  final TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search(String value) {
    setState(() => query = value);
    context.read<DependentSchoolCubit>().search(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DependentSchoolCubit, DependentSchoolState>(
      listenWhen: (previous, current) =>
          current.resolveFailure != previous.resolveFailure ||
          current.updateFailure != previous.updateFailure,
      listener: (context, state) {
        final resolveFailure = state.resolveFailure;
        final updateFailure = state.updateFailure;
        if (resolveFailure != null) {
          VanepFeedback.showError(
            context,
            dependentSchoolFailureLabel(l10n, resolveFailure),
          );
        } else if (updateFailure != null) {
          VanepFeedback.showError(
            context,
            dependentFailureLabel(l10n, updateFailure),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              onChanged: search,
              enabled: !state.isSaving,
              textInputAction: TextInputAction.search,
              cursorColor: VanepColors.action,
              style: VanepTypography.fieldValue,
              decoration: vanepInputDecoration(
                hintText: l10n.dependentSchoolSearchHint,
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 20),
            VanepMapPlaceholder(
              pinIcon: Icons.school,
              label: state.selectedName,
            ),
            const SizedBox(height: 20),
            DependentSchoolResults(
              state: state,
              query: query,
              onSelected: context.read<DependentSchoolCubit>().selectSuggestion,
            ),
          ],
        );
      },
    );
  }
}

class DependentSchoolResults extends StatelessWidget {
  const DependentSchoolResults({
    required this.state,
    required this.query,
    required this.onSelected,
    super.key,
  });

  final DependentSchoolState state;
  final String query;
  final ValueChanged<PlaceSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedPlace = state.selectedPlace;
    final currentSchool = state.snapshot.school;
    final rows = <Widget>[
      if (selectedPlace != null && !state.suggestions.contains(selectedPlace))
        DependentSchoolOption(
          title: selectedPlace.primaryText,
          subtitle: selectedPlace.secondaryText,
          isSelected: true,
        )
      else if (state.isCurrentSchoolSelected && currentSchool != null)
        DependentSchoolOption(
          title: currentSchool.name,
          subtitle: dependentSchoolAddressLabel(currentSchool.address),
          isSelected: true,
        ),
      for (final suggestion in state.suggestions)
        DependentSchoolOption(
          title: suggestion.primaryText,
          subtitle: suggestion.secondaryText,
          isSelected: suggestion == selectedPlace,
          onTap: state.isSaving ? null : () => onSelected(suggestion),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.searchFailure != null) ...[
          DependentSchoolSearchMessage(
            text: l10n.dependentSchoolSearchUnavailable,
            isWarning: true,
          ),
          const SizedBox(height: 12),
        ],
        if (rows.isNotEmpty)
          DependentsListCard(rows: rows)
        else if (state.searchFailure == null)
          DependentSchoolSearchMessage(
            text: query.trim().length >= placeAutocompleteMinimumCharacters
                ? l10n.dependentSchoolSearchEmpty
                : l10n.dependentSchoolSearchPrompt,
          ),
      ],
    );
  }
}

class DependentSchoolOption extends StatelessWidget {
  const DependentSchoolOption({
    required this.title,
    required this.isSelected,
    this.subtitle,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: VanepTypography.cardTitle.copyWith(fontSize: 15),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: VanepTypography.cardSubtitle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isSelected ? VanepColors.action : VanepColors.divider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DependentSchoolSearchMessage extends StatelessWidget {
  const DependentSchoolSearchMessage({
    required this.text,
    this.isWarning = false,
    super.key,
  });

  final String text;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? VanepColors.warningText
        : VanepColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWarning ? VanepColors.warningSurfaceSoft : VanepColors.card,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(
          color: isWarning ? VanepColors.warningBorder : VanepColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.error_outline : Icons.search,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: VanepTypography.cardSubtitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
