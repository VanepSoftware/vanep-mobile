import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class FindVanEmptyView extends StatelessWidget {
  const FindVanEmptyView({
    required this.onClearSearch,
    super.key,
  });

  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.palette.actionSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.findVanEmptyRegionTitle,
              textAlign: TextAlign.center,
              style: context.typography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.driverSearchEmpty,
              textAlign: TextAlign.center,
              style: context.typography.cardSubtitle,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.findVanEmptyRegionSubtitle,
              textAlign: TextAlign.center,
              style: context.typography.cardSubtitle,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.findVanClearSearch),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.palette.action,
                side: BorderSide(color: context.palette.action),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
