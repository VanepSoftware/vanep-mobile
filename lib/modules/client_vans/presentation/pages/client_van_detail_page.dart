import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';

Future<void> openClientVanDetail(
  BuildContext context, {
  required ClientVan van,
  VoidCallback? onChatWithDriver,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ClientVanDetailPage(
        van: van,
        onChatWithDriver: onChatWithDriver,
      ),
    ),
  );
}

class ClientVanDetailPage extends StatelessWidget {
  const ClientVanDetailPage({
    required this.van,
    this.onChatWithDriver,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onChatWithDriver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = van.vehicle;
    final driver = van.driver;
    final contract = van.contract;
    final dependents = van.dependents;

    final statusBg = van.isActive
        ? context.palette.successSurface
        : context.palette.warningSurface;
    final statusFg = van.isActive
        ? context.palette.success
        : context.palette.warning;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: vehicle.displayName,
        caption: l10n.clientVanDetailCaption,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        children: [
          // 1. Vehicle Hero Banner
          _DetailVehicleBanner(
            vehicle: vehicle,
            statusBg: statusBg,
            statusFg: statusFg,
            isActive: van.isActive,
            statusLabel: clientVanStatusLabel(l10n, van.status),
          ),
          const SizedBox(height: 20),

          // 2. Vehicle Details Section
          VanepSection(
            title: l10n.clientVanDetailVehicleSection,
            child: VanepCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailInfoRow(
                    label: 'Marca / Modelo',
                    value: vehicle.displayName,
                  ),
                  if (vehicle.plate != null && vehicle.plate!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailInfoRow(
                      label: l10n.clientVanDetailPlate,
                      value: vehicle.plate!,
                    ),
                  ],
                  const Divider(height: 20),
                  _DetailInfoRow(
                    label: l10n.clientVanDetailYear,
                    value: '${vehicle.manufactureYear}',
                  ),
                  const Divider(height: 20),
                  _DetailInfoRow(
                    label: l10n.clientVanDetailColor,
                    value: vehicle.color,
                  ),
                  const Divider(height: 20),
                  _DetailInfoRow(
                    label: l10n.clientVanDetailCapacity,
                    value: l10n.clientVansSeats(vehicle.capacity),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Driver Responsible Section
          VanepSection(
            title: l10n.clientVansDriverSection,
            child: VanepCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VanepAvatar(
                        photoUrl: driver.photoUrl,
                        initials: initialsOf(driver.name),
                        size: 52,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: context.typography.cardTitle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            if (driver.phone != null &&
                                driver.phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: context.palette.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    driver.phone!,
                                    style: context.typography.cardSubtitle,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (driver.rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.palette.warningSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                driver.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.palette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (onChatWithDriver != null) ...[
                    const SizedBox(height: 16),
                    VanepPrimaryButton(
                      label: l10n.clientVansChatDriver,
                      trailingIcon: Icons.chat_bubble_outline_rounded,
                      onPressed: onChatWithDriver,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Contract Section
          if (contract != null) ...[
            VanepSection(
              title: l10n.clientVansContractSection,
              child: VanepCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatMoney(
                            l10n,
                            (contract.installmentAmount * 100).round(),
                          ),
                          style: context.typography.pageTitle.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.palette.action,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('/ mês', style: context.typography.cardSubtitle),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.clientVansDueDay(contract.dueDay),
                      style: context.typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _DetailInfoRow(
                      label: 'Período de vigência',
                      value: clientVanContractPeriod(l10n, contract),
                    ),
                    const Divider(height: 20),
                    _DetailInfoRow(
                      label: 'Parcelas contratadas',
                      value: '${contract.installments} parcelas',
                    ),
                    const Divider(height: 20),
                    _DetailInfoRow(
                      label: 'Valor total',
                      value: formatMoney(
                        l10n,
                        (contract.totalAmount * 100).round(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 5. Dependents Section
          if (dependents.isNotEmpty) ...[
            VanepSection(
              title: l10n.clientVansDependentsSection,
              child: Column(
                children: [
                  for (final (index, dep) in dependents.indexed) ...[
                    if (index > 0) const SizedBox(height: 12),
                    VanepCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: context.palette.actionSurface,
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 20,
                                  color: context.palette.action,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dep.name,
                                  style: context.typography.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _DetailInfoRow(
                            label: 'Colégio',
                            value: dep.schoolName,
                          ),
                          const Divider(height: 20),
                          _DetailInfoRow(
                            label: l10n.clientVanDetailShift,
                            value: dep.shift,
                          ),
                          const Divider(height: 20),
                          _DetailInfoRow(
                            label: l10n.clientVanDetailPickupAddress,
                            value: dep.pickupAddress,
                          ),
                          if (dep.pickupTime != null ||
                              dep.returnTime != null) ...[
                            const Divider(height: 20),
                            _DetailInfoRow(
                              label: l10n.clientVanDetailSchedule,
                              value: [
                                if (dep.pickupTime != null)
                                  'Ida: ${dep.pickupTime}',
                                if (dep.returnTime != null)
                                  'Volta: ${dep.returnTime}',
                              ].join(' · '),
                            ),
                          ],
                          if (dep.weekdays.isNotEmpty) ...[
                            const Divider(height: 20),
                            Text(
                              l10n.clientVanDetailWeekdays,
                              style: context.typography.cardSubtitle,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final day in dep.weekdays)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.palette.actionSurface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: context.palette.action,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailVehicleBanner extends StatelessWidget {
  const _DetailVehicleBanner({
    required this.vehicle,
    required this.statusBg,
    required this.statusFg,
    required this.isActive,
    required this.statusLabel,
  });

  final ClientVanVehicle vehicle;
  final Color statusBg;
  final Color statusFg;
  final bool isActive;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final photo = vehicle.photoFrontUrl ?? vehicle.photoSideUrl;
    final image = apiImageFor(context, photo);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.palette.action.withValues(alpha: 0.15),
              context.palette.action.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            if (image != null)
              Positioned.fill(
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholderBanner(context),
                ),
              )
            else
              _placeholderBanner(context),
            Positioned(
              top: 14,
              right: 14,
              child: VanepChip(
                label: statusLabel,
                background: statusBg,
                foreground: statusFg,
                icon: isActive ? Icons.check_circle_outline : Icons.schedule,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBanner(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airport_shuttle_rounded,
            size: 56,
            color: context.palette.action.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            vehicle.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: context.typography.cardSubtitle),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.typography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
