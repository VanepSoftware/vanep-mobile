import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/postal_address_display.dart';
import '../../../../core/ui/vanep_address_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/dependent_failure.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../pages/dependent_address_form_page.dart';

class DependentAddressCard extends StatelessWidget {
  const DependentAddressCard({required this.state, super.key});

  final DependentFormState state;

  String? errorLabel(AppLocalizations l10n) {
    if (state.failure is DependentCityNotFoundFailure) {
      return l10n.dependentFailureCityNotFound;
    }
    if (state.addressIssues.isNotEmpty) return l10n.dependentAddressIncomplete;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();
    final address = state.draft.address;

    void edit() {
      if (!state.isSaving) openDependentAddressFormPage(context);
    }

    return VanepAddressCard(
      title: l10n.dependentFieldAddress,
      emptyLabel: l10n.dependentFieldAddressEmpty,
      registerLabel: l10n.dependentAddressRegisterAction,
      menuTooltip: l10n.dependentAddressMenuTooltip,
      editLabel: l10n.dependentAddressEditAction,
      clearLabel: l10n.dependentFieldAddressRemove,
      summary: address.isBlank ? null : postalDraftDisplayFields(address),
      errorText: errorLabel(l10n),
      onRegister: edit,
      onEdit: edit,
      onClear: () {
        if (!state.isSaving) cubit.clearAddress();
      },
    );
  }
}
