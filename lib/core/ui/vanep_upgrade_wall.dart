import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';

/// Blocks the app behind a non-dismissible dialog while the Google Play
/// version is newer than the installed one. Only the semantic version is
/// compared (1.0.0 < 1.0.1); the build number is ignored.
///
/// The check runs on every app open and on resume. If the store cannot be
/// reached or parsed, the app is not blocked.
class VanepUpgradeWall extends StatefulWidget {
  const VanepUpgradeWall({required this.child, this.upgrader, super.key});

  final Widget child;

  /// Overrides the default Play Store upgrader (used by tests).
  final Upgrader? upgrader;

  @override
  State<VanepUpgradeWall> createState() => _VanepUpgradeWallState();
}

class _VanepUpgradeWallState extends State<VanepUpgradeWall> {
  late final Upgrader _upgrader = widget.upgrader ?? VanepUpgrader();

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: _upgrader,
      barrierDismissible: false,
      showPrompt: false,
      showIgnore: false,
      showLater: false,
      showReleaseNotes: false,
      shouldPopScope: () => false,
      child: widget.child,
    );
  }
}

class VanepUpgrader extends Upgrader {
  VanepUpgrader({super.debugLogging})
    : super(
        // Play Store listing is scraped per locale; the app is Brazil-only.
        countryCode: 'BR',
        languageCode: 'pt',
        // Show on every open instead of the default once-every-3-days.
        durationUntilAlertAgain: Duration.zero,
        // Only Google Play for now; the iOS app is not published yet.
        storeController: UpgraderStoreController(oniOS: null),
      );

  @override
  UpgraderMessages determineMessages(BuildContext context) =>
      VanepUpgraderMessages(AppLocalizations.of(context)!);
}

class VanepUpgraderMessages extends UpgraderMessages {
  VanepUpgraderMessages(this.l10n) : super(code: l10n.localeName);

  final AppLocalizations l10n;

  @override
  String? message(UpgraderMessage messageKey) => switch (messageKey) {
    UpgraderMessage.title => l10n.upgradeWallTitle,
    UpgraderMessage.body => l10n.upgradeWallBody,
    UpgraderMessage.buttonTitleUpdate => l10n.upgradeWallButton,
    _ => super.message(messageKey),
  };
}
