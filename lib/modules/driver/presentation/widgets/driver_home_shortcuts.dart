import 'package:flutter/material.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';

class DriverHomeShortcuts extends StatelessWidget {
  const DriverHomeShortcuts({
    super.key,
    required this.data,
    required this.rules,
    required this.onOpen,
  });

  final DriverHomeData data;
  final DriverHomeRules rules;
  final ValueChanged<Shortcut> onOpen;

  List<(Shortcut, String, IconData)> items(BuildContext context) => [
    (
      Shortcut.students,
      AppLocalizations.of(context)!.driverHomeStudents,
      Icons.groups_outlined,
    ),
    (
      Shortcut.route,
      AppLocalizations.of(context)!.driverHomeRoute,
      Icons.route_outlined,
    ),
    (
      Shortcut.absences,
      AppLocalizations.of(context)!.driverHomeAbsences,
      Icons.event_busy_outlined,
    ),
    (
      Shortcut.financial,
      AppLocalizations.of(context)!.driverHomeFinancial,
      Icons.receipt_long_outlined,
    ),
    (
      Shortcut.assistants,
      AppLocalizations.of(context)!.driverHomeAssistants,
      Icons.supervisor_account_outlined,
    ),
    (
      Shortcut.documents,
      AppLocalizations.of(context)!.driverHomeDocumentsShortcut,
      Icons.description_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DriverSectionHeader(title: l10n.driverHomeShortcutsTitle),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (shortcut, label, icon) in items(context))
                  DriverShortcutTileButton(
                    width: width,
                    label: label,
                    icon: icon,
                    enabled: rules.shortcutEnabled(data, shortcut),
                    onTap: () => onOpen(shortcut),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DriverShortcutTileButton extends StatelessWidget {
  const DriverShortcutTileButton({
    required this.width,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final double width;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enabled ? 1.0 : 0.48,
    child: SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: DriverHomeTokens.surface,
          foregroundColor: DriverHomeTokens.textPrimary,
          disabledForegroundColor: DriverHomeTokens.textPrimary,
          disabledBackgroundColor: DriverHomeTokens.surface,
          side: const BorderSide(color: DriverHomeTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
          ),
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
        ),
        onPressed: enabled ? onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 74),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: DriverHomeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DriverHomeTokens.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
