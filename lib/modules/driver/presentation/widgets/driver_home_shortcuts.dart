import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';

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
      Icons.payments_outlined,
    ),
    (
      Shortcut.assistants,
      AppLocalizations.of(context)!.driverHomeAssistants,
      Icons.support_agent_outlined,
    ),
    (
      Shortcut.documents,
      AppLocalizations.of(context)!.driverHomeDocumentsShortcut,
      Icons.description_outlined,
    ),
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      // Ordem fixa: três atalhos por linha, sem reordenar pelos estados.
      final width = (box.maxWidth - 16) / 3;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (shortcut, label, icon) in items(context))
            SizedBox(
              width: width,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: rules.shortcutEnabled(data, shortcut)
                    ? () => onOpen(shortcut)
                    : null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 88),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon),
                      const SizedBox(height: 8),
                      Text(label, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
