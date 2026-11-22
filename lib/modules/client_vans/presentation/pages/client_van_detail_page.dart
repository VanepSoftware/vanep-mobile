import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_hero_card.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_sections.dart';

Future<void> openClientVanDetail(
  BuildContext context, {
  required ClientVan van,
  VoidCallback? onChatWithDriver,
  ValueChanged<ClientVanDependent>? onDependentTapped,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ClientVanDetailPage(
        van: van,
        onChatWithDriver: onChatWithDriver,
        onDependentTapped: onDependentTapped,
      ),
    ),
  );
}

class ClientVanDetailPage extends StatelessWidget {
  const ClientVanDetailPage({
    required this.van,
    this.onChatWithDriver,
    this.onDependentTapped,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onChatWithDriver;
  final ValueChanged<ClientVanDependent>? onDependentTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = van.vehicle;
    final contract = van.contract;
    final dependents = van.dependents;

    void openSoon(String title) {
      openComingSoonPage(
        context,
        title: title,
        message: l10n.comingSoon,
      );
    }

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: vehicle.displayName,
        caption: l10n.clientVanDetailCaption,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        children: [
          ClientVanHeroCard(
            van: van,
            onChatTapped: onChatWithDriver,
            onCallTapped: () => _showDriverPhoneSheet(context, l10n),
          ),
          const SizedBox(height: 20),
          if (dependents.isNotEmpty)
            ClientVanDependentsSection(
              dependents: dependents,
              onDependentTapped: (dep) {
                if (onDependentTapped != null) {
                  onDependentTapped!(dep);
                  return;
                }
                _showSchedulesSheet(context, l10n);
              },
            )
          else
            ClientVanGroupedSection(
              title: l10n.clientVansOnVanSection,
              rows: [
                ClientVanMenuRow(
                  leading: const ClientVanIconLeading(icon: Icons.face_outlined),
                  title: l10n.clientVanNoDependents,
                ),
              ],
            ),
          const SizedBox(height: 20),
          ClientVanRoutineSection(
            van: van,
            onScheduleTapped: () => _showSchedulesSheet(context, l10n),
            onFeatureTapped: openSoon,
          ),
          const SizedBox(height: 20),
          if (contract != null)
            ClientVanContractSection(
              contract: contract,
              onContractTapped: () => _showContractSheet(context, l10n, contract),
              onPaymentsTapped: () => openSoon(l10n.clientVansPaymentsRowTitle),
            )
          else
            ClientVanGroupedSection(
              title: l10n.clientVansContractPaymentsSection,
              rows: [
                ClientVanMenuRow(
                  leading: const ClientVanIconLeading(
                    icon: Icons.description_outlined,
                  ),
                  title: l10n.clientVansContractRowTitle,
                  subtitle: l10n.clientVanNoContract,
                ),
              ],
            ),
          const SizedBox(height: 20),
          ClientVanSecuritySection(
            van: van,
            onDocumentsTapped: () => _showDocumentsSheet(context, l10n),
            onFeatureTapped: openSoon,
          ),
        ],
      ),
    );
  }

  Future<void> _showDriverPhoneSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final phone = van.driver.phone?.trim() ?? '';
    return _showDetailSheet(
      context,
      title: l10n.clientVanDriverPhoneTitle,
      buildChildren: (sheetContext) => [
        _DetailInfoRow(label: l10n.clientVansDriverRole, value: van.driver.name),
        const Divider(height: 20),
        Text(
          phone.isNotEmpty ? phone : l10n.clientVanDriverPhoneMissing,
          style: sheetContext.typography.cardTitle.copyWith(fontSize: 18),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: phone));
                Navigator.of(sheetContext).pop();
                VanepFeedback.showInfo(context, l10n.clientVanPhoneCopied);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(l10n.clientVanCopyPhone),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showSchedulesSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return _showDetailSheet(
      context,
      title: l10n.clientVansScheduleStopsTitle,
      buildChildren: (sheetContext) => [
        if (van.dependents.isEmpty)
          Text(
            l10n.clientVanNoDependents,
            style: sheetContext.typography.cardSubtitle,
          )
        else
          for (final (index, dep) in van.dependents.indexed) ...[
            if (index > 0) const Divider(height: 24),
            Text(
              dep.name,
              style: sheetContext.typography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _DetailInfoRow(label: l10n.clientVanDetailSchool, value: dep.schoolName),
            const Divider(height: 16),
            _DetailInfoRow(
              label: l10n.clientVanDetailShift,
              value: clientVanShiftLabel(l10n, dep.shift),
            ),
            if (dep.pickupAddress.trim().isNotEmpty) ...[
              const Divider(height: 16),
              _DetailInfoRow(
                label: l10n.clientVanDetailPickupAddress,
                value: dep.pickupAddress,
              ),
            ],
            if (dep.pickupTime != null || dep.returnTime != null) ...[
              const Divider(height: 16),
              _DetailInfoRow(
                label: l10n.clientVanDetailSchedule,
                value: [
                  if (dep.pickupTime != null)
                    l10n.clientVanDetailOutboundTime(dep.pickupTime!),
                  if (dep.returnTime != null)
                    l10n.clientVanDetailReturnTime(dep.returnTime!),
                ].join(' · '),
              ),
            ],
            if (dep.weekdays.isNotEmpty) ...[
              const Divider(height: 16),
              _DetailInfoRow(
                label: l10n.clientVanDetailWeekdays,
                value: dep.weekdays.join(', '),
              ),
            ],
          ],
      ],
    );
  }

  Future<void> _showContractSheet(
    BuildContext context,
    AppLocalizations l10n,
    ClientVanContract contract,
  ) {
    return _showDetailSheet(
      context,
      title: l10n.clientVansContractRowTitle,
      buildChildren: (_) => [
        _DetailInfoRow(
          label: l10n.clientVansContractSection,
          value: clientVanStatusLabel(l10n, contract.status),
        ),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailMonthlyFee,
          value: formatMoney(l10n, (contract.installmentAmount * 100).round()),
        ),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailDueDate,
          value: l10n.clientVansDueDay(contract.dueDay),
        ),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailContractPeriod,
          value: clientVanContractPeriod(l10n, contract),
        ),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailInstallmentsLabel,
          value: l10n.clientVanDetailInstallmentsCount(contract.installments),
        ),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailTotalAmount,
          value: formatMoney(l10n, (contract.totalAmount * 100).round()),
        ),
      ],
    );
  }

  Future<void> _showDocumentsSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final vehicle = van.vehicle;
    return _showDetailSheet(
      context,
      title: l10n.clientVansDocumentsTitle,
      buildChildren: (_) => [
        _DetailInfoRow(
          label: l10n.clientVanDetailBrandModel,
          value: vehicle.displayName,
        ),
        if (vehicle.plate != null && vehicle.plate!.isNotEmpty) ...[
          const Divider(height: 18),
          _DetailInfoRow(label: l10n.clientVanDetailPlate, value: vehicle.plate!),
        ],
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailYear,
          value: '${vehicle.manufactureYear}',
        ),
        const Divider(height: 18),
        _DetailInfoRow(label: l10n.clientVanDetailColor, value: vehicle.color),
        const Divider(height: 18),
        _DetailInfoRow(
          label: l10n.clientVanDetailCapacity,
          value: l10n.clientVansSeats(vehicle.capacity),
        ),
        const Divider(height: 18),
        _DetailInfoRow(label: l10n.clientVansDriverRole, value: van.driver.name),
      ],
    );
  }

  Future<void> _showDetailSheet(
    BuildContext context, {
    required String title,
    required List<Widget> Function(BuildContext sheetContext) buildChildren,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: sheetContext.typography.sectionTitle.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...buildChildren(sheetContext),
                ],
              ),
            ),
          ),
        );
      },
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
          flex: 4,
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: context.typography.cardSubtitle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
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
