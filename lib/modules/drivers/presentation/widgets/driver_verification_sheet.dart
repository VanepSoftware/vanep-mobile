import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class DriverVerificationSheet extends StatelessWidget {
  const DriverVerificationSheet({required this.driverName, super.key});

  final String driverName;

  static Future<void> show(
    BuildContext context, {
    required String driverName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DriverVerificationSheet(driverName: driverName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      l10n.driverProfileVerifiedDocCnh,
      l10n.driverProfileVerifiedDocCourse,
      l10n.driverProfileVerifiedDocBackground,
      l10n.driverProfileVerifiedDocInspection,
      l10n.driverProfileVerifiedDocAuthorization,
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.palette.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: context.palette.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverProfileVerifiedCardTitle,
                        style: context.typography.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(driverName, style: context.typography.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < items.length; i++) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: context.palette.success,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(items[i], style: context.typography.body),
                  ),
                ],
              ),
              if (i < items.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: context.palette.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.driverProfileVerifiedSheetIntro,
                      style: context.typography.cardSubtitle.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            VanepPrimaryButton(
              label: l10n.driverProfileVerifiedGotIt,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
