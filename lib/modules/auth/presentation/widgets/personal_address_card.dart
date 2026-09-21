import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_confirm_dialog.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_secondary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/personal_address.dart';
import '../cubit/personal_data_cubit.dart';
import '../formatters/personal_address_display.dart';
import '../pages/personal_address_form_page.dart';

enum PersonalAddressCardAction { edit, clear }

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

    return VanepOutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.personalAddressCardTitle,
                  style: VanepTypography.cardTitle,
                ),
              ),
              if (saved != null) const PersonalAddressCardMenu(),
            ],
          ),
          const SizedBox(height: 12),
          if (saved == null)
            const PersonalAddressEmpty()
          else
            PersonalAddressSummary(address: saved),
        ],
      ),
    );
  }
}

class PersonalAddressEmpty extends StatelessWidget {
  const PersonalAddressEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.home_outlined,
              color: VanepColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.personalAddressEmpty,
                style: VanepTypography.cardSubtitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        VanepSecondaryButton(
          label: l10n.personalAddressRegisterAction,
          icon: Icons.add,
          onPressed: () => openPersonalAddressFormPage(context),
        ),
      ],
    );
  }
}

class PersonalAddressSummary extends StatelessWidget {
  const PersonalAddressSummary({required this.address, super.key});

  final PersonalAddress address;

  @override
  Widget build(BuildContext context) {
    final fields = personalAddressDisplayFields(address);
    final details = [
      if (fields.neighborhood != null) fields.neighborhood!,
      fields.cityState,
      if (fields.zipCode != null) fields.zipCode!,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.home_outlined,
            color: VanepColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fields.street, style: VanepTypography.fieldValue),
              const SizedBox(height: 2),
              Text(details, style: VanepTypography.cardSubtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class PersonalAddressCardMenu extends StatelessWidget {
  const PersonalAddressCardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<PersonalAddressCardAction>(
      tooltip: l10n.personalAddressCardMenuTooltip,
      icon: const Icon(Icons.more_vert, color: VanepColors.textSecondary),
      color: VanepColors.card,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case PersonalAddressCardAction.edit:
            openPersonalAddressFormPage(context);
          case PersonalAddressCardAction.clear:
            confirmClearPersonalAddress(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PersonalAddressCardAction.edit,
          child: PersonalAddressMenuItem(
            icon: Icons.edit_outlined,
            label: l10n.personalAddressEditAction,
          ),
        ),
        PopupMenuItem(
          value: PersonalAddressCardAction.clear,
          child: PersonalAddressMenuItem(
            icon: Icons.delete_outline,
            label: l10n.personalAddressClearAction,
            color: VanepColors.danger,
          ),
        ),
      ],
    );
  }
}

class PersonalAddressMenuItem extends StatelessWidget {
  const PersonalAddressMenuItem({
    required this.icon,
    required this.label,
    this.color = VanepColors.textPrimary,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: VanepTypography.fieldValue.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
