import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';
import 'package:vanep_mobile/modules/settings/presentation/formatters/theme_preference_label.dart';

Future<void> openSettingsPage(BuildContext context) {
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ThemePreferenceCubit, ThemePreferenceState>(
      listenWhen: (previous, current) =>
          current.failure != null && previous.failure != current.failure,
      listener: (context, _) =>
          VanepFeedback.showError(context, l10n.settingsThemeSaveFailed),
      child: Scaffold(
        backgroundColor: context.palette.surface,
        appBar: VanepAppBar(title: l10n.profileSettings),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ThemePreferenceSection(),
            SizedBox(height: 24),
            AppVersionFooter(),
          ],
        ),
      ),
    );
  }
}

class ThemePreferenceSection extends StatelessWidget {
  const ThemePreferenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = context.select(
      (ThemePreferenceCubit cubit) => cubit.state.preference,
    );
    return VanepSection(
      title: l10n.settingsAppearanceTitle,
      child: VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VanepSegmentedControl<ThemePreference>(
              segments: [
                for (final preference in ThemePreference.values)
                  VanepSegment(
                    value: preference,
                    label: themePreferenceLabel(l10n, preference),
                  ),
              ],
              selected: selected,
              onSelected: context
                  .read<ThemePreferenceCubit>()
                  .selectThemePreference,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsThemeSystemHint,
              style: context.typography.cardSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class AppVersionFooter extends StatefulWidget {
  const AppVersionFooter({super.key});

  @override
  State<AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<AppVersionFooter> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Center(
          child: Text(
            l10n.settingsAppVersion(info.version, info.buildNumber),
            style: context.typography.cardSubtitle,
          ),
        );
      },
    );
  }
}
