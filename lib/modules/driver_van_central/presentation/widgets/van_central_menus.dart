import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_menu_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/formatters/van_central_labels.dart';

class VanCentralActions {
  const VanCentralActions({
    required this.onRegisterVan,
    required this.onOpenVanDetails,
    required this.onOpenServiceAreas,
    required this.onOpenComingSoon,
    required this.onAcceptingStudentsChanged,
  });

  final VoidCallback onRegisterVan;
  final VoidCallback onOpenVanDetails;
  final VoidCallback onOpenServiceAreas;
  final ValueChanged<String> onOpenComingSoon;
  final ValueChanged<bool> onAcceptingStudentsChanged;
}

class VanCentralSection extends StatelessWidget {
  const VanCentralSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<VanepMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: VanepTypography.sectionTitle),
        const SizedBox(height: 10),
        VanepMenuCard(items: items),
      ],
    );
  }
}

class VanCentralMenus extends StatelessWidget {
  const VanCentralMenus({
    required this.state,
    required this.actions,
    super.key,
  });

  final VanCentralState state;
  final VanCentralActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final occupancy = state.occupancy;
    final assistants = state.assistants;
    final serviceAreas = state.serviceAreas;
    final attendance = state.attendance;

    VanepMenuItem comingSoonItem(String label, IconData icon, String hint) {
      return VanepMenuItem(
        label: label,
        icon: icon,
        subtitle: hint,
        onTap: () => actions.onOpenComingSoon(label),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VanCentralSection(
          title: l10n.vanCentralOperation,
          items: [
            comingSoonItem(
              l10n.vanCentralRoute,
              Icons.route_outlined,
              l10n.vanCentralRouteHint,
            ),
            comingSoonItem(
              l10n.vanCentralStudents,
              Icons.groups_outlined,
              occupancy == null
                  ? l10n.vanCentralStudentsHint
                  : studentsSummary(l10n, occupancy),
            ),
            comingSoonItem(
              l10n.vanCentralAbsences,
              Icons.event_busy_outlined,
              l10n.vanCentralAbsencesHint,
            ),
            comingSoonItem(
              l10n.vanCentralHistory,
              Icons.history,
              l10n.vanCentralHistoryHint,
            ),
          ],
        ),
        const SizedBox(height: 18),
        VanCentralSection(
          title: l10n.vanCentralTeam,
          items: [
            comingSoonItem(
              l10n.vanCentralAssistants,
              Icons.supervisor_account_outlined,
              assistants == null
                  ? l10n.vanCentralAssistantsHint
                  : assistantsSummary(l10n, assistants),
            ),
          ],
        ),
        const SizedBox(height: 18),
        VanCentralSection(
          title: l10n.vanCentralVan,
          items: [
            VanepMenuItem(
              label: l10n.vanCentralVanData,
              icon: Icons.photo_camera_outlined,
              subtitle: l10n.vanCentralVanDataHint,
              onTap: actions.onOpenVanDetails,
            ),
            comingSoonItem(
              l10n.vanCentralVanDocuments,
              Icons.description_outlined,
              l10n.vanCentralVanDocumentsHint,
            ),
          ],
        ),
        const SizedBox(height: 18),
        VanCentralSection(
          title: l10n.vanCentralAttendance,
          items: [
            if (attendance != null)
              VanepMenuItem(
                label: l10n.vanCentralAccepting,
                icon: Icons.how_to_reg_outlined,
                subtitle: acceptingStudentsSummary(
                  l10n,
                  attendance: attendance,
                  occupancy: occupancy,
                  capacity: state.selectedVan?.capacity,
                ),
                onTap: state.isChangingAttendance
                    ? null
                    : () => actions.onAcceptingStudentsChanged(
                        !attendance.acceptingStudents,
                      ),
                trailing: Switch(
                  value: attendance.acceptingStudents,
                  activeTrackColor: VanepColors.action,
                  onChanged: state.isChangingAttendance
                      ? null
                      : actions.onAcceptingStudentsChanged,
                ),
              ),
            VanepMenuItem(
              label: l10n.vanCentralServiceAreas,
              icon: Icons.map_outlined,
              subtitle: serviceAreas == null
                  ? l10n.vanCentralServiceAreasHint
                  : serviceAreasSummary(l10n, serviceAreas),
              onTap: actions.onOpenServiceAreas,
            ),
            if (attendance != null)
              comingSoonItem(
                l10n.vanCentralBasePrice,
                Icons.sell_outlined,
                basePriceSummary(l10n, attendance),
              ),
          ],
        ),
      ],
    );
  }
}

class VanCentralLockedMenus extends StatelessWidget {
  const VanCentralLockedMenus({
    required this.state,
    required this.actions,
    super.key,
  });

  final VanCentralState state;
  final VanCentralActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceAreas = state.serviceAreas;

    VanepMenuItem lockedItem(String label, IconData icon, String hint) {
      return VanepMenuItem(
        label: label,
        icon: icon,
        subtitle: hint,
        enabled: false,
        trailing: const Icon(Icons.lock_outline, color: VanepColors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VanCentralSection(
          title: l10n.vanCentralLockedSection,
          items: [
            lockedItem(
              l10n.vanCentralRoute,
              Icons.route_outlined,
              l10n.vanCentralRouteHint,
            ),
            lockedItem(
              l10n.vanCentralStudents,
              Icons.groups_outlined,
              l10n.vanCentralStudentsHint,
            ),
            lockedItem(
              l10n.vanCentralAssistants,
              Icons.supervisor_account_outlined,
              l10n.vanCentralAssistantsHint,
            ),
            lockedItem(
              l10n.vanCentralVanDocuments,
              Icons.description_outlined,
              l10n.vanCentralVanDocumentsHint,
            ),
          ],
        ),
        const SizedBox(height: 22),
        VanCentralSection(
          title: l10n.vanCentralReadySection,
          items: [
            VanepMenuItem(
              label: l10n.vanCentralServiceAreas,
              icon: Icons.map_outlined,
              subtitle: serviceAreas == null || serviceAreas.isEmpty
                  ? l10n.vanCentralServiceAreasHint
                  : serviceAreasSummary(l10n, serviceAreas),
              onTap: actions.onOpenServiceAreas,
            ),
          ],
        ),
      ],
    );
  }
}
