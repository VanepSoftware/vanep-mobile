import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';

/// Prompts the user to update when Google Play has a newer version.
///
/// There are two levels, decided by [minAppVersion]:
/// - installed < [minAppVersion]: blocking, non-dismissible dialog.
/// - installed < Play version but >= [minAppVersion]: dismissible notice,
///   shown at most once a day.
///
/// [minAppVersion] comes from Firebase Remote Config, so the team can raise it
/// (only once the rollout reaches everyone) without shipping a release. When it
/// is null or invalid nothing is ever blocked. Only the semantic version is
/// compared (1.0.0 < 1.0.1); the build number is ignored.
///
/// If the store cannot be reached or parsed, the app is not blocked.
class VanepUpgradeWall extends StatefulWidget {
  const VanepUpgradeWall({
    required this.child,
    this.minAppVersion,
    this.upgrader,
    super.key,
  });

  final Widget child;

  /// Minimum supported version; below it the app is blocked.
  final String? minAppVersion;

  /// Overrides the default Play Store upgrader (used by tests).
  final Upgrader? upgrader;

  @override
  State<VanepUpgradeWall> createState() => _VanepUpgradeWallState();
}

class _VanepUpgradeWallState extends State<VanepUpgradeWall> {
  late final Upgrader _upgrader =
      widget.upgrader ?? VanepUpgrader(minAppVersion: widget.minAppVersion);

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: _upgrader,
      // Tapping outside never dismisses. The "later" button (soft notice only)
      // and the system back button (see shouldPopScope) are the exits.
      barrierDismissible: false,
      showPrompt: false,
      showIgnore: false,
      // Upgrader hides "later" on its own while the update is mandatory.
      showLater: true,
      showReleaseNotes: false,
      shouldPopScope: () => !_upgrader.blocked(),
      child: widget.child,
    );
  }
}

class VanepUpgrader extends Upgrader {
  VanepUpgrader({
    super.minAppVersion,
    super.upgraderOS,
    super.debugLogging,
    UpgraderStoreController? storeController,
  }) : super(
         // Only Google Play for now; the iOS app is not published yet.
         storeController:
             storeController ?? UpgraderStoreController(oniOS: null),
         // Play Store listing is scraped per locale; the app is Brazil-only.
         countryCode: 'BR',
         languageCode: 'pt',
         // Soft notice: don't nag on every open. Mandatory updates ignore this.
         durationUntilAlertAgain: const Duration(days: 1),
       );

  @override
  UpgraderMessages determineMessages(BuildContext context) =>
      VanepUpgraderMessages(
        AppLocalizations.of(context)!,
        mandatory: blocked(),
      );
}

class VanepUpgraderMessages extends UpgraderMessages {
  VanepUpgraderMessages(this.l10n, {required this.mandatory})
    : super(code: l10n.localeName);

  final AppLocalizations l10n;
  final bool mandatory;

  @override
  String? message(UpgraderMessage messageKey) => switch (messageKey) {
    UpgraderMessage.title =>
      mandatory ? l10n.upgradeWallTitle : l10n.upgradeNoticeTitle,
    UpgraderMessage.body =>
      mandatory ? l10n.upgradeWallBody : l10n.upgradeNoticeBody,
    UpgraderMessage.buttonTitleUpdate => l10n.upgradeWallButton,
    UpgraderMessage.buttonTitleLater => l10n.upgradeNoticeLater,
    _ => super.message(messageKey),
  };
}
