import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';

class ClientVanCard extends StatelessWidget {
  const ClientVanCard({
    required this.van,
    this.onTap,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = van.vehicle;
    final driver = van.driver;
    final dependents = van.dependents;

    final statusBg = van.isActive
        ? context.palette.successSurface
        : context.palette.warningSurface;
    final statusFg = van.isActive
        ? context.palette.success
        : context.palette.warning;

    return VanepCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Vehicle Header + Status + Chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.palette.actionSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.airport_shuttle_rounded,
                  color: context.palette.action,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: context.typography.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (vehicle != null &&
                        vehicle.displayName.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicle.displayName,
                        style: context.typography.cardSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VanepChip(
                label: clientVanStatusLabel(l10n, van.status),
                background: statusBg,
                foreground: statusFg,
                icon: van.isActive ? Icons.check_circle_outline : Icons.schedule,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: context.palette.textSecondary,
                size: 22,
              ),
            ],
          ),

          // 2. Dependents minimal preview
          if (dependents.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.face_outlined,
                  size: 16,
                  color: context.palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dependents.map((d) => d.name).join(', '),
                    style: context.typography.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
