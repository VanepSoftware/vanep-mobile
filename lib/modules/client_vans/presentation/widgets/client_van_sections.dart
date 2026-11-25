import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

class ClientVanGroupedSection extends StatelessWidget {
  const ClientVanGroupedSection({
    required this.title,
    required this.rows,
    super.key,
  });

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: context.typography.sectionTitle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: context.palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: context.palette.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.palette.divider,
                  ),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ClientVanMenuRow extends StatelessWidget {
  const ClientVanMenuRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.cardTitle.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDestructive
                          ? context.palette.dangerText
                          : context.palette.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.cardSubtitle.copyWith(
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: context.palette.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ClientVanIconLeading extends StatelessWidget {
  const ClientVanIconLeading({
    required this.icon,
    this.isDestructive = false,
    super.key,
  });

  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDestructive
            ? context.palette.dangerSurface
            : context.palette.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDestructive
            ? context.palette.dangerText
            : context.palette.textSecondary,
      ),
    );
  }
}

class ClientVanDependentsSection extends StatelessWidget {
  const ClientVanDependentsSection({
    required this.dependents,
    this.onTap,
    this.onDependentTapped,
    super.key,
  });

  final List<ClientVanDependent> dependents;
  final VoidCallback? onTap;
  final ValueChanged<ClientVanDependent>? onDependentTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClientVanGroupedSection(
      title: l10n.clientVansOnVanSection,
      rows: [
        for (final dep in dependents)
          ClientVanMenuRow(
            leading: VanepInitialAvatar(
              name: dep.name,
              seed: dep.token,
              size: 38,
            ),
            title: dep.name,
            subtitle: _dependentSubtitle(l10n, dep),
            onTap: onDependentTapped != null
                ? () => onDependentTapped!(dep)
                : onTap,
          ),
      ],
    );
  }

  String _dependentSubtitle(AppLocalizations l10n, ClientVanDependent dep) {
    final shift = clientVanShiftLabel(l10n, dep.shift);
    final parts = <String>[
      if (dep.schoolName.trim().isNotEmpty) dep.schoolName.trim(),
      if (shift.isNotEmpty) shift,
      if (dep.weekdays.isNotEmpty) dep.weekdays.join(', '),
    ];
    return parts.join(' · ');
  }
}

class ClientVanRoutineSection extends StatelessWidget {
  const ClientVanRoutineSection({
    required this.van,
    required this.onScheduleTapped,
    required this.onFeatureTapped,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onScheduleTapped;
  final ValueChanged<String> onFeatureTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstDep = van.dependents.isEmpty ? null : van.dependents.first;
    final scheduleSubtitle = _scheduleSubtitle(l10n, firstDep);

    return ClientVanGroupedSection(
      title: l10n.clientVansRoutineSection,
      rows: [
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(icon: Icons.schedule_outlined),
          title: l10n.clientVansScheduleStopsTitle,
          subtitle: scheduleSubtitle,
          onTap: onScheduleTapped,
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(icon: Icons.event_busy_outlined),
          title: l10n.clientVansReportAbsenceTitle,
          subtitle: l10n.clientVansReportAbsenceSubtitle,
          onTap: () => onFeatureTapped(l10n.clientVansReportAbsenceTitle),
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(
            icon: Icons.edit_location_alt_outlined,
          ),
          title: l10n.clientVansAdjustStopTitle,
          subtitle: l10n.clientVansAdjustStopSubtitle,
          onTap: () => onFeatureTapped(l10n.clientVansAdjustStopTitle),
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(icon: Icons.history_rounded),
          title: l10n.clientVansTripHistoryTitle,
          subtitle: l10n.clientVansTripHistorySubtitle,
          onTap: () => onFeatureTapped(l10n.clientVansTripHistoryTitle),
        ),
      ],
    );
  }

  String? _scheduleSubtitle(AppLocalizations l10n, ClientVanDependent? dep) {
    if (dep == null) return null;
    if (dep.pickupTime != null && dep.returnTime != null) {
      return l10n.clientVansScheduleBothTimes(dep.pickupTime!, dep.returnTime!);
    }
    if (dep.pickupTime != null) {
      return l10n.clientVansSchedulePickupOnly(dep.pickupTime!);
    }
    if (dep.pickupAddress.trim().isNotEmpty) return dep.pickupAddress;
    return null;
  }
}

class ClientVanContractSection extends StatelessWidget {
  const ClientVanContractSection({
    required this.contract,
    required this.onContractTapped,
    required this.onPaymentsTapped,
    super.key,
  });

  final ClientVanContract contract;
  final VoidCallback? onContractTapped;
  final VoidCallback onPaymentsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contractSummary = _contractSummary(l10n);
    final dueDay = contract.dueDay;

    return ClientVanGroupedSection(
      title: l10n.clientVansContractPaymentsSection,
      rows: [
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(icon: Icons.description_outlined),
          title: l10n.clientVansContractRowTitle,
          subtitle: contractSummary,
          onTap: onContractTapped,
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(
            icon: Icons.receipt_long_outlined,
          ),
          title: l10n.clientVansPaymentsRowTitle,
          subtitle: dueDay == null ? null : l10n.clientVansDueDay(dueDay),
          onTap: onPaymentsTapped,
        ),
      ],
    );
  }

  String? _contractSummary(AppLocalizations l10n) {
    final endsOn = contract.endsOn;
    final installmentAmount = contract.installmentAmount;
    if (endsOn != null && installmentAmount != null) {
      final date = DateFormat('dd/MM/yyyy').format(endsOn);
      final amount = formatMoney(l10n, (installmentAmount * 100).round());
      return l10n.clientVansContractUntilSummary(date, amount);
    }
    if (installmentAmount != null) {
      return '${formatMoney(l10n, (installmentAmount * 100).round())}/mês';
    }
    if (endsOn != null) {
      return DateFormat('dd/MM/yyyy').format(endsOn);
    }
    return null;
  }
}

class ClientVanSecuritySection extends StatelessWidget {
  const ClientVanSecuritySection({
    required this.van,
    required this.onDocumentsTapped,
    required this.onFeatureTapped,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onDocumentsTapped;
  final ValueChanged<String> onFeatureTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final driverFirst = dependentFirstName(van.driver.name);
    final vehicle = van.vehicle;
    final vehicleDocSubtitle = vehicle == null
        ? null
        : [
            if (vehicle.displayName.trim().isNotEmpty) vehicle.displayName,
            if (vehicle.manufactureYear != null) '${vehicle.manufactureYear}',
          ].join(' · ');

    return ClientVanGroupedSection(
      title: l10n.clientVansSecuritySection,
      rows: [
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(
            icon: Icons.verified_user_outlined,
          ),
          title: l10n.clientVansDocumentsTitle,
          subtitle: vehicleDocSubtitle == null || vehicleDocSubtitle.isEmpty
              ? van.driver.name
              : vehicleDocSubtitle,
          onTap: onDocumentsTapped,
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(icon: Icons.star_outline_rounded),
          title: l10n.clientVansRateDriverTitle(driverFirst),
          subtitle: l10n.clientVansRateDriverSubtitle,
          onTap: () => onFeatureTapped(l10n.clientVansRateDriverTitle(driverFirst)),
        ),
        ClientVanMenuRow(
          leading: const ClientVanIconLeading(
            icon: Icons.cancel_outlined,
            isDestructive: true,
          ),
          title: l10n.clientVansCancelContractTitle,
          subtitle: l10n.clientVansCancelContractSubtitle,
          isDestructive: true,
          onTap: () => onFeatureTapped(l10n.clientVansCancelContractTitle),
        ),
      ],
    );
  }
}
