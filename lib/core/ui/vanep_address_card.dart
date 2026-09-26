import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import '../formatters/postal_address_display.dart';
import 'vanep_page_chrome.dart';
import 'vanep_secondary_button.dart';

enum VanepAddressCardAction { edit, clear }

class VanepAddressCard extends StatelessWidget {
  const VanepAddressCard({
    required this.title,
    required this.emptyLabel,
    required this.registerLabel,
    required this.menuTooltip,
    required this.editLabel,
    required this.clearLabel,
    required this.onRegister,
    required this.onEdit,
    required this.onClear,
    this.summary,
    this.errorText,
    super.key,
  });

  final String title;
  final String emptyLabel;
  final String registerLabel;
  final String menuTooltip;
  final String editLabel;
  final String clearLabel;
  final VoidCallback onRegister;
  final VoidCallback onEdit;
  final VoidCallback onClear;
  final PostalAddressDisplayFields? summary;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    final errorText = this.errorText;

    return VanepOutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: VanepTypography.cardTitle)),
              if (summary != null)
                VanepAddressCardMenu(
                  tooltip: menuTooltip,
                  editLabel: editLabel,
                  clearLabel: clearLabel,
                  onEdit: onEdit,
                  onClear: onClear,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary == null)
            VanepAddressEmpty(
              label: emptyLabel,
              registerLabel: registerLabel,
              onRegister: onRegister,
            )
          else
            VanepAddressSummary(fields: summary),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VanepAddressEmpty extends StatelessWidget {
  const VanepAddressEmpty({
    required this.label,
    required this.registerLabel,
    required this.onRegister,
    super.key,
  });

  final String label;
  final String registerLabel;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: Text(label, style: VanepTypography.cardSubtitle)),
          ],
        ),
        const SizedBox(height: 16),
        VanepSecondaryButton(
          label: registerLabel,
          icon: Icons.add,
          onPressed: onRegister,
        ),
      ],
    );
  }
}

class VanepAddressSummary extends StatelessWidget {
  const VanepAddressSummary({required this.fields, super.key});

  final PostalAddressDisplayFields fields;

  @override
  Widget build(BuildContext context) {
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
              Text(fields.details, style: VanepTypography.cardSubtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class VanepAddressCardMenu extends StatelessWidget {
  const VanepAddressCardMenu({
    required this.tooltip,
    required this.editLabel,
    required this.clearLabel,
    required this.onEdit,
    required this.onClear,
    super.key,
  });

  final String tooltip;
  final String editLabel;
  final String clearLabel;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VanepAddressCardAction>(
      tooltip: tooltip,
      icon: const Icon(Icons.more_vert, color: VanepColors.textSecondary),
      color: VanepColors.card,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case VanepAddressCardAction.edit:
            onEdit();
          case VanepAddressCardAction.clear:
            onClear();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: VanepAddressCardAction.edit,
          child: VanepAddressMenuItem(
            icon: Icons.edit_outlined,
            label: editLabel,
          ),
        ),
        PopupMenuItem(
          value: VanepAddressCardAction.clear,
          child: VanepAddressMenuItem(
            icon: Icons.delete_outline,
            label: clearLabel,
            color: VanepColors.danger,
          ),
        ),
      ],
    );
  }
}

class VanepAddressMenuItem extends StatelessWidget {
  const VanepAddressMenuItem({
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
