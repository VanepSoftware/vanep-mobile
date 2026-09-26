import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/vanep_address_card.dart';
import '../../../../core/ui/vanep_confirm_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/personal_address.dart';
import '../cubit/personal_data_cubit.dart';
import '../formatters/personal_address_display.dart';
import '../pages/personal_address_form_page.dart';

Future<void> openPersonalAddressFormPage(BuildContext context) {
  final cubit = context.read<PersonalDataCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const PersonalAddressFormPage(),
      ),
    ),
  );
}

Future<void> confirmClearPersonalAddress(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<PersonalDataCubit>();
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.personalAddressClearTitle,
    message: l10n.personalAddressClearMessage,
    confirmLabel: l10n.personalAddressClearConfirm,
    cancelLabel: l10n.profileSignOutCancel,
    isDestructive: true,
  );
  if (!confirmed) return;
  await cubit.clearAddress();
}

class PersonalAddressCard extends StatelessWidget {
  const PersonalAddressCard({required this.address, super.key});

  final PersonalAddress? address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saved = address;

    return VanepAddressCard(
      title: l10n.personalAddressCardTitle,
      emptyLabel: l10n.personalAddressEmpty,
      registerLabel: l10n.personalAddressRegisterAction,
      menuTooltip: l10n.personalAddressCardMenuTooltip,
      editLabel: l10n.personalAddressEditAction,
      clearLabel: l10n.personalAddressClearAction,
      summary: saved == null ? null : personalAddressDisplayFields(saved),
      onRegister: () => openPersonalAddressFormPage(context),
      onEdit: () => openPersonalAddressFormPage(context),
      onClear: () => confirmClearPersonalAddress(context),
    );
  }
}
